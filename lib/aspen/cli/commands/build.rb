module Aspen
  module CLI
    module Commands

      # TODO Refactor build into Build::Steps
      class Build < Dry::CLI::Command
        desc "Build Aspen project"

        def call(*)
          f = Dry::CLI::Utils::Files

          # Check if we're in an Aspen project
          unless f.exist?('.aspen')
            raise ArgumentError, "Must be within an Aspen project to run `build`"
          end

          puts "----> Converting non-Aspen to Aspen (bin/convert)"
          if f.exist?('bin/convert')
            unless system('bin/convert')
              raise RuntimeError, "`bin/convert` didn't work, stopping build. See above Traceback."
            end
          end

          # Grab all the grammars and Aspen source files,
          # make into one main Aspen file.
          puts "----> Collecting main.aspen from src/ and src/grammars"

          # Clear the build/ folder.
          Dir["build/*"].each { |file| f.delete(file) }

          @grammars = "" # Main grammars IO
          @aspens   = "" # Main Aspen IO

          manifest = YAML.load_file('manifest.yml') if f.exist?('manifest.yml')

          Dir['src/grammars/*.aspen'].map do |path|
            # Skip if there's an ignore: src: in the manifest, and if it matches the file path
            next if manifest.dig("ignore", "grammars") && manifest.dig("ignore", "grammars").any? { |ignore_path| Regexp.new(ignore_path) =~ path }
            @grammars << File.read(path)
          end
          Dir['src/*.aspen'].map do |path|
            next if manifest.dig("ignore", "src") && manifest.dig("ignore", "src").any? { |ignore_path| Regexp.new(ignore_path) =~ path }
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

          main_aspen = File.open("build/main-#{Time.now.to_i}.aspen", 'w') do |file|
            file << @grammars
            file << Aspen::SEPARATOR + "\n"
            file << @aspens
          end

          puts "----> Compiling main Aspen file (#{main_aspen.path})"
          # Compile the main Aspen file, according to manifest.yml
          if manifest
            manifest["output"].each do |format|
              adapter = Aspen::Adapters::Registry.get(format.downcase.to_sym)
              out_path = main_aspen.path.gsub(/\.aspen$/, '') + adapter.ext

              File.open(out_path, 'w') do |file|
                file << Aspen.compile_text(File.read(main_aspen), adapter: adapter.id)
              end
              puts "----> Compiled main #{adapter.name} file"
            end
          else
            # TODO: Add better documentation about this, and move this
            # upward in Confident Ruby style.
            raise ArgumentError, "Requires manifest.yml with outputs"
          end
        end
      end

    end
  end
end
