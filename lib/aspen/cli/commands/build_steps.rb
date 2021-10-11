require 'airtable'

module Aspen
  module CLI
    module Commands
      module BuildSteps

        class BuildStep
          def manifest
            return @manifest if @manifest
            @manifest = @files.exist?('manifest.yml') ? YAML.load_file('manifest.yml') : {}
          end

          def config
            return @config if @config
            @config = {}
            Dir['config/*.yml'].each do |path|
              key = File.basename(path, File.extname(path))
              value = YAML.load_file(path)
              @config[key.to_s] = value
            end
            @config
          end

          def call(*)
            @files = Dry::CLI::Utils::Files
          end
        end


        class CheckAspenProject < BuildStep
          # Check if we're in an Aspen project, and stop if not.
          def call(*)
            super
            unless @files.exist?('.aspen')
              raise ArgumentError, "Must be within an Aspen project to run `build`"
            end
          end
        end # / CheckAspenProject


        class DownloadAttachedResources < BuildStep
          def call(*)
            super
            return false unless manifest['attached']
            check_for_save_file
            if cache_expired?
              download
              update_save_file!
            else
              puts "----> Skipping download, cache is still good."
            end
          end

          def check_for_save_file
            unless @files.exist?('build/last-download')
              File.open('build/last-download', 'w') { |f| f << 0 }
            end
          end

          def cache_expired?
            if manifest["cache_seconds"]
              last = File.read('build/last-download').to_i       # Last download time
              time_since_last_download = (Time.now - last).to_i  # Time since last download
              threshhold = manifest['cache_seconds'].to_i        # Cache threshhold
              time_since_last_download > threshhold
            end
          end

          def update_save_file!
            File.open('build/last-download', 'w') { |f| f << Time.now.to_i }
          end

          def download
            puts '----> Downloading attached resources'
            manifest['attached'].each do |resource|
              puts "      > Downloading #{resource["name"]} (#{resource["source"].capitalize})"
              case resource["source"]
              when "airtable" then download_airtable_resource(resource)
              end
            end
          end

          def download_airtable_resource(resource)
            client = Airtable::Client.new(config.dig('airtable', 'api_key'))
            table = client.table(resource['app_id'], resource['table'])
            out_path = "src/#{resource["name"].downcase.gsub(" ", "_")}.csv"
            CSV.open(out_path, 'w') do |file|
              columns = Array(resource['columns'])
              file << columns
              table.records.each do |record|
                file << columns.map { |col| record[col] }
              end
            end
          end

        end # / DownloadAttachedResources

        class ConvertIntoAspen < BuildStep
          def call(*)
            super
            puts "----> Converting non-Aspen to Aspen (bin/convert)"
            if @files.exist?('bin/convert')
              unless system('bin/convert')
                raise RuntimeError, "`bin/convert` didn't work, stopping build. See above Traceback."
              end
            end
          end
        end # / ConvertIntoAspen


        class CollectMainAspen < BuildStep
          def call(*)
            super
            # Grab all the grammars and Aspen source files, make into one main Aspen file.
            puts "----> Collecting main.aspen from src/ and src/grammars"

            # Clear the build/ folder
            Dir["build/main-*"].each { |path| @files.delete(path)}

            @grammars = "" # Main grammars IO
            @aspens   = "" # Main Aspen IO

            collect_grammars
            collect_aspen

            main_aspen = File.open("build/main-#{Time.now.to_i}.aspen", 'w') do |file|
              file << @grammars
              file << Aspen::SEPARATOR + "\n"
              file << @aspens
            end
            return main_aspen
          end

          def collect_grammars
            Dir['src/grammars/*.aspen'].map do |path|
              # Skip if there's an ignore: src: in the manifest, and if it matches the file path
              next if manifest.dig("ignore", "grammars") && manifest.dig("ignore", "grammars").any? { |ignore_path| Regexp.new(ignore_path) =~ path }
              @grammars << File.read(path)
            end
          end

          def collect_aspen
            Dir['src/*.aspen'].map do |path|
              next if manifest.dig("ignore", "src") && manifest.dig("ignore", "src").any? do |ignore_path|
                Regexp.new(ignore_path) =~ path
              end
              File.read(path)
            end.compact.each do |file|
              if file.include?(SEPARATOR)
                env, _sep, code = file.partition(SEPARATOR)
                @grammars << env
                @aspens << code
              else
                @aspens << file
              end
            end
          end
        end # / CollectMainAspen


        class CompileMainAspen < BuildStep

          def call(main_aspen_file)
            super
            puts "----> Compiling main Aspen file (#{main_aspen_file.path})"
            # Compile the main Aspen file, according to manifest.yml
            unless manifest["output"]
              puts "      Defaulting to Cypher output. To customize, set up a manifest.yml."
            end

            outputs = manifest["output"] ? Array(manifest["output"]) : ["Cypher"]

            outputs.each do |format|
              adapter = Aspen::Adapters::Registry.get(format.downcase.to_sym)
              out_path = main_aspen_file.path.gsub(/\.aspen$/, '') + adapter.ext

              File.open(out_path, 'w') do |file|
                file << Aspen.compile_text(File.read(main_aspen_file), adapter: adapter.id)
              end
              puts "----> Compiled main #{adapter.name} file"
            end
          end
        end # / CompileMainAspen

      end
    end
  end
end
