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
          default: "http://neo4j:pass@localhost:7474/",
          required: false

        option :docker,
          desc: "Generate a Docker Compose file for a Neo4j database",
          type: :boolean,
          default: true,
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

          File.open("#{project_name}/manifest.yml", 'w') do |file|
            template = get_template_file('manifest.yml.erb')
            file << ERB.new(template).result_with_hash(project_name: project_name)
          end
          puts "    #{project_name}/manifest.yml          -> Metadata about included files"

          f.touch "#{project_name}/config/db.yml"
          File.open("#{project_name}/config/db.yml", 'w') do |file|
            template = get_template_file('db.yml.erb')
            file << ERB.new(template).result_with_hash(database_url: options[:database_url])
          end
          puts "    #{project_name}/config/db.yml         -> Database configuration"

          if options[:docker]
            f.cp get_template_path("docker-compose.yml"), "#{project_name}/docker-compose.yml"
            puts "    #{project_name}/docker-compose.yml    -> Docker Compose file for Neo4j"
          else
            puts "    Skipping Docker Compose file"
          end

          f.mkdir "#{project_name}/src/"
          puts "    #{project_name}/src/                  -> Source files"

          f.mkdir "#{project_name}/bin/"
          puts "    #{project_name}/bin/                  -> Binary files (scripts)"

          f.cp get_template_path("convert"), "#{project_name}/bin/convert"
          FileUtils.chmod("+x", "#{project_name}/bin/convert")
          puts "    #{project_name}/bin/convert           -> Converts non-Aspen to Aspen"

          f.mkdir "#{project_name}/src/discourses/"
          f.touch "#{project_name}/src/discourses/.gitkeep"
          puts "    #{project_name}/src/discourses/       -> Collection of Discourses"

          f.mkdir "#{project_name}/src/grammars/"
          f.touch "#{project_name}/src/grammars/.gitkeep"
          puts "    #{project_name}/src/grammars/         -> Collection of Grammars"

          f.mkdir "#{project_name}/build/"
          f.touch "#{project_name}/build/.gitkeep"
          puts "    #{project_name}/build/                -> Compilation is output here"

          f.cp get_template_path(".gitignore"), "#{project_name}/.gitignore"
          f.touch "#{project_name}/.gitignore"
          puts "    #{project_name}/.gitignore            -> Ignoring config files, build files"

          if options[:docker]
            puts "\nTo start the Neo4j database, run `docker-compose up` from the #{project_name} folder"
          end
          puts "\n✅ Generated new project '#{project_name}'\n\n"
        end

        def get_template_file(name)
          File.read(
            get_template_path(name)
          )
        end

        def get_template_path(name)
          File.expand_path(
            File.join(
              File.dirname(__FILE__), "..", "templates", name
            )
          )
        end
      end

    end
  end
end
