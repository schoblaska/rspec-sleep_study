# Sleep Study
Sleep Study is an RSpec formatter that shows you which specs are spending the most time in `sleep`, and where exactly in your code those `sleep`s are happening.

The `sleep` method can be a useful tool, especially in networking code (eg: backing off after hitting a rate limit, inserting a pause between polls of a remote job status, etc). In your test environment, however, those `sleep`s are generally unnecessary, and it's easy to forget to stub them and end up with specs that are wasting time `sleep`ing for no reason, adding to your build time. Running Sleep Study will identify these specs for you.

## RUNNING SLEEP STUDY WILL SLOW DOWN YOUR SPECS
Sleep Study works by putting [tracers](https://ruby-doc.org/core-2.0.0/TracePoint.html) around every call and return of every C routine that your code calls, and saving benchmarking data if that routine is a `sleep` function. As you might expect, running Ruby code involves executing a _lot_ of C routines. Those tracers are not free, and having them in place can add an extra 20-25% to your specs' execution time. As such, it's a good idea to run Sleep Study either in a separate CI build, or only occasionally to audit your test suite.

## Usage
After adding `rspec-sleep_study` to your Gemfile, run RSpec with the `--format RSpec::SleepStudy` option. (If you want the normal progress report as well, you can run RSpec with both formatters: `--format progress --format RSpec::SleepStudy`)

## Example
```
bundle exec rspec --format RSpec::SleepStudy spec/

The following examples spent the most time in `sleep`:
  20.57 seconds: ./spec/features/user_sends_email_spec.rb:23
    - 7.46 seconds: ./lib/api_client.rb:12
    - 6.752 seconds: ./gems/selenium-webdriver/lib/selenium/webdriver/common/socket_poller.rb:108
  14.06 seconds: ./spec/features/apply_filters_spec.rb:39
    - 5.21 seconds: ./lib/api_client.rb:12
  10.0 seconds: ./spec/features/password_reset_email_spec.rb:22
  10.0 seconds: ./spec/features/password_reset_email_spec.rb:47
  9.06 seconds: ./spec/features/dashboard_spec.rb:49
  8.54 seconds: ./spec/features/apply_filters_spec.rb:96
  8.17 seconds: ./spec/features/dashboard_spec.rb:7
  6.69 seconds: ./spec/features/create_new_widget_spec.rb:26
  6.63 seconds: ./spec/features/create_report_spec.rb:18
  6.41 seconds: ./spec/features/create_new_widget_spec.rb:14
```
