#-------------------------------------------------------------------------------
#
# Copyright 2013-2018 Trimble Inc.
# License: The MIT License (MIT)
#
#-------------------------------------------------------------------------------

# require 'testup/runs'

module TestUp
  class TestRunnerWindow

    def initialize
      @dialog = create_dialog
      # on(:close) {
      #   @preferences_window.close unless @preferences_window.nil?
      # }
    end

    def toggle
      if @dialog.visible?
        @dialog.close
      else
        @dialog.show
      end
    end

    # --------------------------------------------------------------------------

    def active_testsuite
      # @bridge.call('TestUp.TestSuites.active')
    end

    def selected_tests
      # @bridge.call('TestUp.TestSuite.selected_tests')
    end

    # @param [Array<Hash>] results
    def update_results(results)
      # Debugger.time('JS:TestUp.update_results') {
      #   @bridge.call('TestUp.update_results', results)
      # }
    end

    # Clears and reloads the test suites.
    def reload
      # return false unless visible?
      # self.bridge.call('TestUp.reset')
      # discover_tests
      # true
    end

    private

    def create_dialog
      filename = File.join(PATH, 'html', 'runner.html')
      options = {
        :title           => PLUGIN_NAME,
        :preferences_key => PLUGIN_ID,
        :width           => 400,
        :height          => 400,
        :resizable       => true
      }
      # dialog = UI::WebDialog.new(options)
      dialog = UI::HtmlDialog.new(options)
      dialog.set_file(filename)
      dialog.add_action_callback('ready') { |dialog, params|
        puts 'Log: Ready'
        event_testup_ready
      }
      dialog
    end

    def call(function, *args)
      arguments = args.map { |arg| JSON.pretty_generate(arg) }
      argument_js = arguments.join(', ');
      @dialog.execute_script("#{function}(#{argument_js});")
    end

    # Intercept callbacks from the SKUI window before passing it on to SKUI.
    def callback_handler(webdialog, callback, arguments)
      case callback
      when 'TestUp.on_script_debugger_attached'
        ScriptDebugger.attach
      when 'TestUp.on_run'
        event_testup_run
      when 'TestUp.on_rerun'
        event_testup_rerun
      when 'TestUp.on_discover'
        event_discover
      when 'TestUp.on_open_source_file'
        event_opent_source_file(arguments[0])
      when 'TestUp.on_preferences'
        event_on_open_preferences
      when 'TestUp.TestSuites.on_change'
        event_change_testsuite(arguments[0])
      when 'TestUp.Console.output'
        event_console_output(arguments[0])
      end
    ensure
      super
      nil
    end

    def discover_tests(first_run = false)
      discoveries = TestUp.discover_tests
      # js_command = 'TestUp.TestSuites.update'
      # js_command = "#{js_command}_first_run" if first_run
      # Debugger.time("JS:#{js_command}") {
      Debugger.time("JS:update(...)") {
        progress = TaskbarProgress.new
        begin
          progress.set_state(TaskbarProgress::INDETERMINATE)
          # self.bridge.call(js_command, discoveries)
          call('app.update', discoveries)
        ensure
          progress.set_state(TaskbarProgress::NOPROGRESS)
        end
      }
      nil
    end

    def event_testup_ready
      config = {
        :active_tab => TestUp.settings[:last_active_testsuite],
        :debugger   => ScriptDebugger.attached?,
        :path       => PATH
      }
      # self.bridge.call('TestUp.init', config)
      call('app.init', config)
      discover_tests(true)
    end

    def event_testup_run
      # To avoid the "Slow running script" dialog in IE the call to execute
      # the tests is deferred.
      TestUp.defer {
        discover_tests # TODO(thomthom): Why is this needed?
        TestUp.run_tests_gui
      }
    end

    def event_testup_rerun
      run_file = TestUp::Runs.select_config
      return unless run_file
      run_config = TestUp::Runs.read_config(run_file)
      # To avoid the "Slow running script" dialog in IE the call to execute
      # the tests is deferred.
      TestUp.defer {
        discover_tests # TODO(thomthom): Why is this needed?
        TestUp.run_tests_gui(run_config)
        puts "Re-run of: #{run_file}"
      }
    end

    def event_discover
      discover_tests
    end

    def event_change_testsuite(testsuite)
      TestUp.settings[:last_active_testsuite] = testsuite
    end

    def event_console_output(value)
      Debugger.output(value)
    end

    def event_opent_source_file(location)
      puts "TestUp.open_source_file(#{location})"
      result = location.match(/^(.+):(\d+)?$/)
      if result
        filename = result[1]
        line_number = result[2]
      else
        filename = location
        line_number = 0
      end
      unless File.exist?(filename)
        warn "Unable to find: #{filename}"
        warn 'Trying to account for encoding bug...'
        warn filename
        filename = filename.encode('ISO-8859-1')
        warn filename
        filename.force_encoding('UTF-8')
        warn filename
        warn "Exists: #{File.exist?(filename)}"
      end
      if File.exist?(filename)
        Editor.open_file(filename, line_number)
      else
        UI.beep
        warn "Unable to open: #{filename}"
        p filename.bytes
      end
    end

    def event_on_open_preferences
      #@preferences_window ||= PreferencesWindow.new
      @preferences_window = PreferencesWindow.new
      @preferences_window.show
    end

  end # class
end # module
