max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
threads max_threads_count, max_threads_count
port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "development")
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
plugin :tmp_restart
