namespace :app do
  namespace :db do
    desc 'Dump production database to localhost'

    task production: :environment do
      Bundler.with_unbundled_env do
        Figaro.load # Load ENV variables
        sh "scalingo --app mmibordeaux-teach backups-create --addon #{ENV['PG_ADDON_ID']}"
        sh "scalingo --app mmibordeaux-teach backups-download --addon #{ENV['PG_ADDON_ID']} --output db/scalingo-dump.tar.gz"
        sh 'rm -f db/latest.dump' # Remove an old backup file if it exists
        sh 'tar zxvf db/scalingo-dump.tar.gz -C db/' # Extract the new backup archive
        sh 'rm db/scalingo-dump.tar.gz' # Remove the backup archive
        sh 'mv db/*.pgsql db/latest.dump' # Rename the backup file
        sh 'DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:drop'
        sh 'bundle exec rails db:create'
        sh 'pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d mmibordeaux db/latest.dump'
      end
    end
  end
end
