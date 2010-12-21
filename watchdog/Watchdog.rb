require 'sys/proctable'
require 'watchdog/WatchedProcess'
require 'watchdog/WatchedSite'
require 'shared/OutputHandler'
require 'nil/file'
require 'shared/sites'

class Watchdog
  def initialize(configuration, connections)
    logPaths = Nil.joinPaths(configuration::Logging::Path, configuration::Watchdog::Log)
    @output = OutputHandler.new(logPaths)
    @database = connections.sqlDatabase
    @notification = connections.notificationClient
    watchdogData = configuration::Watchdog
    @programs = watchdogData::Programs.map do |name, pattern|
      WatchedProcess.new(name, Regexp.new(pattern))
    end
    @gracePeriod = watchdogData::GracePeriod
    @delay = watchdogData::Delay
    @adminIDs = getAdminIDs
    @sites = getReleaseSites(connections).map{|site| WatchedSite.new(site)}
    puts "Number of administrators: #{@adminIDs.size}"
  end

  def getAdminIDs
    users = @database[:user_data]
    ids = users.where(is_administrator: true).select(:id)
    ids = ids.map {|x| x[:id]}
    return ids
  end

  def output(line)
    @output.output(line)
  end

  def notifyAdmins(message, severity = 'error')
    output message
    @adminIDs.each do |id|
      @notification.serviceMessage(id, severity, message)
    end
  end

  def performProcessChecks
    @programs.each do |program|
      program.isActive = false
    end
    begin
      Sys::ProcTable.ps do |process|
        offset = @programs.index(process)
        next if offset == nil
        program = @programs[offset]
        program.isActive = true
      end
    rescue SystemCallError => exception
      puts "An exception occured: #{exception.inspect}"
      return
    end
    @programs.each do |program|
      if program.oldIsActive != nil && program.oldIsActive != program.isActive
        #a change occured
        if program.isActive
          #the process was relaunched - this does not require any notification really because the administrator is responsible for this
          output "Service \"#{program.name}\" has been restored"
        else
          #the process terminated - this should never happen
          #notify the adminstrator about this problem
          notifyAdmins "Service \"#{program.name}\" terminated unexpectedly"
        end
      end
      program.oldIsActive = program.isActive
    end
  end

  def performReleaseTimeChecks
    @sites.each do |site|
      rows = site.dataset.select(:release_date).reverse_order(:release_date).limit(1).all
      if rows.empty?
        #the site doesn't have any releases yet
        next
      end
      lastReleaseTime = rows[0][:release_date]
      difference = Time.now.utc - lastReleaseTime
      isLate = difference > @gracePeriod
      if !site.isLate && isLate
        #something is wrong - no new releases have been detected in a long time
        #this means that the observers are failing to get data for some reason
        #intervention by a developer is required
        notifyAdmins "The observer of site \"#{site.name}\" no longer detects new releases and must be fixed"
      elsif site.isLate && !isLate
        notifyAdmins("The observer of site \"#{site.name}\" appears to be back to normal after previously malfunctioning", 'information')
      end
      site.isLate = isLate
    end
  end

  def run
    while true
      performProcessChecks
      performReleaseTimeChecks
      sleep @delay
    end
  end
end
