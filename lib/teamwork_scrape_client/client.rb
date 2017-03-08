require 'mechanize'
require 'json'

module TeamworkScrapeClient
  class Client
    attr_reader :base_url, :email, :password

    def initialize(options = {})
      @email = options[:email]
      @password = options[:password]
      @base_url = options[:base_url] || "https://equisolve.teamwork.com"

      login(email, password)    
    end

    def mech
      @mech ||= Mechanize.new do |m|
        m.log = Logger.new(STDOUT)
      end
    end

    def login(email, password)
      response = mech.post(
        "#{base_url}/v/1/login.json?getInitialPage=true",
        {username: email, password: password, rememberMe: false}.to_json,
        {'Content-Type' => 'application/json'}
      )
    end

    def profile
      response = mech.get('/me.json',
                fullprofile: 1,
                getPreferences: 1,
                cleanPreferences: true,
                getAccounts: 1,
                includeAuth: 1,
                includeClockIn:1)
      JSON.parse(response.body)['profile']
    end

    def account
      return @account if @account
      response = mech.get('/account.json')
      @account = JSON.parse(response.body)['account']
    end

    def project(id)
      response = mech.get("/projects/#{id}.json?getPermissions=true&getNotificationSettings=true&getActivePages=true&getDateInfo=true&getEmailAddress=true&formatMarkdown=false")
      Project.new(JSON.parse(response.body)['project'])
    end

    def company_by_name(company_name)
      response = mech.get("/projects.json?getActivePages=true&searchCompany=true&formatMarkdown=false&status=active&getCategoryPath=1&userId=0&page=1&pageSize=500&orderBy=lastActivityDate&orderMode=DESC")
      projects = JSON.parse(response.body)['projects']
      companies = projects.map { |p| p['company'] }.uniq
      companies.find { |c| c['name'] == company_name }
    end

    def project_by_name(project_name)
      response = mech.get("/projects.json?getActivePages=true&searchCompany=true&formatMarkdown=false&status=active&getCategoryPath=1&userId=0&page=1&pageSize=500&orderBy=lastActivityDate&orderMode=DESC")
      projects = JSON.parse(response.body)['projects']
    end


    def copy_project(options = {})
      old_project_id = options[:old_project_id]
      raise ArgumentError, "old_project_id option is required" unless old_project_id

      new_project_name = options[:new_project_name]
      raise ArgumentError, "new_project_name option is required" unless new_project_name

      new_company_name = options[:new_company_name]
      raise ArgumentError, "new_company_name option is required" unless new_company_name

      # Find an existing company or add a new one
      existing_company = company_by_name(new_company_name)
      existing_company_id = existing_company ? existing_company['id'] : nil

      old_project = project(old_project_id)

      days_offset = 

      response = mech.post('/index.cfm',
                           action: 'CloneProject_CreateProjectClone',
                           id: old_project_id,
                           installationId: account['id'],
                           'cloneproject-action' => 'copy',
                           cloneProjectName: new_project_name,
                           copyTasks: 'YES',
                           copyMilestones: 'YES',
                           copyMessages: 'YES',
                           copyFiles: 'YES',
                           copyLinks: 'YES',
                           copyNotebooks: 'YES',
                           copyTimelogs: 'YES',
                           copyInvoices: 'YES',
                           copyExpenses: 'YES',
                           copyRisks: 'YES',
                           copyPeople: 'YES',
                           daysOffset: old_project.days_offset,
                           keepOffWeekends: '1',
                           createActivityLog: 'YES',
                           createItemsUsingCurrentUser: 'NO',
                           uncomplete: 'YES',
                           copyComments: 'YES',
                           copyProjectRoles: 'YES',
                           copyLogo: 'YES',
                           companyId: existing_company_id || 0,
                           newCompanyName: existing_company_id ? '' : new_company_name
      )

      JSON.parse(response.body)
    end
  end
end