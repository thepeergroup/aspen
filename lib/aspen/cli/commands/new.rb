require 'erb'
require 'fileutils'

module Aspen
  module CLI
    module Commands

      class New < Dry::CLI::Command
        desc "Generate a new Aspen project"

        argument :project_name,
          desc: "Name for new Aspen project",
          required: true

        option :database_url,
          desc: "Database to push Aspen data to",
          aliases: ["d"],
          required: false

        def call(project_name: , **options)
          f = Dry::CLI::Utils::Files

          if f.exist?("#{project_name}/.aspen")
            raise RuntimeError, "There is already an Aspen project at #{project_name}, stopping."
          end

          URI.parse(options[:database_url])

          puts "\nGenerated:"
          puts "----------"

          f.mkdir "#{project_name}/"
          puts "    #{project_name}/                      -> Project folder"

          f.touch "#{project_name}/.aspen"
          puts "    #{project_name}/.aspen                -> File indicating Aspen project "

          f.touch "#{project_name}/manifest.yml"
          puts "    #{project_name}/manifest.yml          -> Metadata about included files"

          f.touch "#{project_name}/.env"
          puts "    #{project_name}/.env                  -> Env vars"

          # Replace with template
          f.touch "#{project_name}/config/db.yml"
          File.open("#{project_name}/config/db.yml", 'w') do |file|
            template = File.read "lib/aspen/cli/templates/db.yml.erb"
            file << ERB.new(template).result_with_hash(database_url: options[:database_url])
          end
          puts "    #{project_name}/config/db.yml         -> Database configuration"

          f.mkdir "#{project_name}/src/"
          puts "    #{project_name}/src/                  -> Source files"

          f.mkdir "#{project_name}/bin/"
          puts "    #{project_name}/bin/                  -> Binary files (scripts)"

          f.cp "lib/aspen/cli/templates/convert", "#{project_name}/bin/convert"
          FileUtils.chmod("+x", "#{project_name}/bin/convert")
          puts "    #{project_name}/bin/convert           -> Converts non-Aspen to Aspen"

          f.mkdir "#{project_name}/src/grammars/"
          puts "    #{project_name}/src/grammars/         -> Aspen Grammar collection"

          f.mkdir "#{project_name}/build/"
          f.touch "#{project_name}/build/.gitkeep"
          puts "    #{project_name}/build/                -> Compilation is output here"

          f.touch "#{project_name}/.gitignore"
          puts "    #{project_name}/.gitignore            -> Ignoring .aspen, .env, build/"

          puts "\n✅ Generated new project '#{project_name}'\n\n\n"
        end
      end

    end
  end
end
