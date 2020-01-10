require 'charty'
require 'benchmark_driver'

class BenchmarkDriver::Output::Charty < BenchmarkDriver::BulkOutput
  DEFAULT_BACKEND = 'pyplot'
  DEFAULT_CHART = 'bar'

  OPTIONS = {
    backend: ['--output-backend BACKEND', Regexp.union(Charty::Backends.names), "Chart backend: #{Charty::Backends.names.join(', ')} (default: #{DEFAULT_BACKEND})"],
    chart: ['--output-chart CHART', Regexp.union(['bar', 'box']), "Specify chart type: bar, box (default: #{DEFAULT_CHART})"],
  }

  # @param [Array<BenchmarkDriver::Metric>] metrics
  # @param [Array<BenchmarkDriver::Job>] jobs
  # @param [Array<BenchmarkDriver::Context>] contexts
  def initialize(contexts:, options:, **)
    super
    @contexts = contexts
    @backend = options.fetch(:backend, DEFAULT_BACKEND).to_sym
    @chart = options.fetch(:chart, DEFAULT_CHART)
  end

  # @param [Hash{ BenchmarkDriver::Job => Hash{ BenchmarkDriver::Context => { BenchmarkDriver::Metric => Float } } }] result
  # @param [Array<BenchmarkDriver::Metric>] metrics
  def bulk_output(job_context_result:, metrics:)
    Charty::Backends.use(@backend)

    metric = metrics.first # only one metric is supported for now
    job_context_result.each do |job, context_result|
      if job_context_result.keys.size > 1
        puts "\n#{job.name}"
      end

      names = context_result.keys.map(&:name)
      case @chart
      when 'bar'
        values = context_result.values.map { |result| result.values.fetch(metric) }
        output = Charty.bar_plot(names, values).render
      when 'box'
        values = context_result.values.first.all_values.fetch(metric).size.times.map { [] }
        context_result.values.each do |result|
          result.all_values.fetch(metric).each_with_index do |value, i|
            values[i] << value
          end
        end
        output = Charty.box_plot(data: Charty::Table.new(values, columns: names)).render
      else
        raise ArgumentError, "unexpected --output-chart: #{@chart}"
      end

      if output
        puts output
      end
    end
  end

  def with_job(job, &block)
    print "#{job.name}: "
    @print_comma = false
    super
    puts
  end

  def with_context(context, &block)
    print ", " if @print_comma
    @print_comma = true
    print context.name
    super
  end
end
