require 'fileutils'

module Aspen
  module CLI
    module Commands

      class New < Dry::CLI::Command
        desc "Generate a new Aspen project"

        argument :project_name,
          desc: "Name for new Aspen project",
          required: true

        def call(project_name: )
          f = Dry::CLI::Utils::Files

          if f.exist?("#{project_name}/.aspen")
            raise RuntimeError, "There is already an Aspen project at #{project_name}, stopping."
          end

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

          f.touch "#{project_name}/config/db.yml"
          puts "    #{project_name}/config/db.yml         -> Database configuration"

          f.mkdir "#{project_name}/src/"
          puts "    #{project_name}/src/                  -> Source files"

          f.mkdir "#{project_name}/bin/"
          puts "    #{project_name}/bin/                  -> Binary files (scripts)"

          f.touch "#{project_name}/bin/convert"
          FileUtils.chmod("+x", "#{project_name}/bin/convert")
          puts "    #{project_name}/bin/convert           -> Converts non-Aspen to Aspen"

          f.mkdir "#{project_name}/src/grammars/"
          puts "    #{project_name}/src/grammars/         -> Aspen Grammar collection"

          f.mkdir "#{project_name}/src/prepare/"
          puts "    #{project_name}/src/prepare/          -> Folder for processing data"

          f.touch "#{project_name}/src/prepare/steps.yml"
          puts "    #{project_name}/src/prepare/steps.yml -> Data processing step metadata"

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
