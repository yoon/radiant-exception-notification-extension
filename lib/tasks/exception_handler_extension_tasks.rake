namespace :radiant do
  namespace :extensions do
    namespace :exception_handler do
      
      desc "Runs the migration of the Exception Handler extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          ExceptionHandlerExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          ExceptionHandlerExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Exception Handler to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[ExceptionHandlerExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(ExceptionHandlerExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
