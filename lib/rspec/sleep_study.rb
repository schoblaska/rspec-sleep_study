require "rspec/core"

module RSpec
  class SleepStudy
    RSpec::Core::Formatters.register self, :dump_summary, :example_started,
                                     :example_failed, :example_passed, :example_pending

    def initialize(output)
      @output = output
      @sleepers = []
      @locs_by_example = {}
      @tracers = [
        TracePoint.new(:c_call) { |tp| start_sleep(tp) if tp.method_id == :sleep },
        TracePoint.new(:c_return) { |tp| end_sleep if tp.method_id == :sleep }
      ]
    end

    def example_started(notification)
      @total_time_slept = 0
      @sleep_starts = []
      @tracers.each(&:enable)
      @locs_by_example[notification.example.id] = {}
      @current_example = notification.example
    end

    def example_ended(notification)
      @tracers.each(&:disable)
      @current_example = nil
      record_time_slept(notification)
    end
    alias example_failed example_ended
    alias example_passed example_ended
    alias example_pending example_ended

    def dump_summary(_notification)
      return unless sleepers_to_report.any?

      @output << "\nThe following examples spent the most time in `sleep`:\n"

      sleepers_to_report.each do |example, slept|
        @output << "  #{slept.round(3)} seconds: #{example.location}\n"

        locs_to_report(example.id, slept).each do |loc, loc_slept|
          @output << "    - #{loc_slept.round(3)} seconds: #{loc}\n"
        end
      end

      @output << "\n"
    end

    private

    def start_sleep(tp)
      @sleep_starts << ["#{tp.path}:#{tp.lineno}", Time.now.to_f]
    end

    def end_sleep
      if @sleep_starts.any?
        sleep_start = @sleep_starts.pop
        loc = sleep_start[0]
        time_slept = Time.now.to_f - sleep_start[1]
        @locs_by_example[@current_example.id][loc] ||= 0
        @locs_by_example[@current_example.id][loc] += time_slept
        @total_time_slept += time_slept
      end
    end

    def sleepers_to_report
      @sleepers.sort_by { |s| -s[1] }[0, 10]
    end

    def locs_to_report(example_id, example_slept)
      @locs_by_example[example_id].select do |_, slept|
        slept >= example_slept * 0.25
      end.sort_by { |_, slept| -slept }
    end

    def record_time_slept(notification)
      return if @total_time_slept <= 0.001
      @sleepers << [notification.example, @total_time_slept]
    end
  end
end
