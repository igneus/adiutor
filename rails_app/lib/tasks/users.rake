class RequestPassword
  def self.call
    print 'Please enter password: '
    password = STDIN.gets.strip
  end
end

desc 'Create new user account'
task :adduser, [:email] => [:environment] do |task, args|
  password = RequestPassword.call

  User.create!(
    email: args.email,
    password: password,
    password_confirmation: password
  )
end

desc 'Change user password'
task :passwd, [:email] => [:environment] do |task, args|
  user = User.find_by_email! args.email
  password = RequestPassword.call

  user.update!(
    password: password,
    password_confirmation: password
  )
end
