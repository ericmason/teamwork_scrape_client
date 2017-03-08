require 'mechanize'
require 'json'

module TeamworkScrapeClient
  class Client
    attr_reader :base_url, :email, :password, :debug

    def initialize(options = {})
      @email = options[:email]
      @password = options[:password]
      @base_url = options[:base_url]
      @debug = options[:debug]

      raise ArgumentError, 'email is required' unless @email
      raise ArgumentError, 'password is required' unless @password
      raise ArgumentError, 'base_url is required' unless @base_url

      login(email, password)
    end

    def mech
      @mech ||= Mechanize.new do |m|
        m.log = Logger.new(STDOUT) if debug
      end
    end

    def login(email, password)
      mech.post(
        "#{base_url}/v/1/login.json?getInitialPage=true",
        { username: email, password: password, rememberMe: false }.to_json,
        { 'Content-Type' => 'application/json' }
      )
    end

    def profile
      response = mech.get('/me.json',
                          fullprofile: 1,
                          getPreferences: 1,
                          cleanPreferences: true,
                          getAccounts: 1,
                          includeAuth: 1,
                          includeClockIn: 1)
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
      projects.find { |p| p['name'] == project_name }
    end

    def copy_project(options = {})
      raise ArgumentError, "old_project_id or old_project_name option is required" unless options[:old_project_name] || options[:old_project_id]

      old_project_id = if options[:old_project_name]
        old_project = project_by_name(options[:old_project_name])
        raise "Project #{options[:old_project_name]} not found" unless old_project
        old_project['id']
      else
        options[:old_project_id]
      end

      new_project_name = options[:new_project_name]
      raise ArgumentError, "new_project_name option is required" unless new_project_name

      new_company_name = options[:new_company_name]
      raise ArgumentError, "new_company_name option is required" unless new_company_name

      # Find an existing company or add a new one
      existing_company = company_by_name(new_company_name)
      existing_company_id = existing_company ? existing_company['id'] : nil

      old_project = project(old_project_id)

      response = mech.post(
        '/index.cfm',
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