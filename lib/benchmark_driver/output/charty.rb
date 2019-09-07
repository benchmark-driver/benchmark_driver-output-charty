require 'charty'
require 'benchmark_driver'

class BenchmarkDriver::Output::Charty < BenchmarkDriver::BulkOutput
  GRAPH_PATH = 'charty.png'

  OPTIONS = {
    chart: ['--output-chart CHART', Regexp.union(['bar', 'box']), 'Specify chart type: bar, box (default: bar)'],
    path: ['--output-path PATH', String, "Chart output path (default: #{GRAPH_PATH})"]
  }

  # @param [Array<BenchmarkDriver::Metric>] metrics
  # @param [Array<BenchmarkDriver::Job>] jobs
  # @param [Array<BenchmarkDriver::Context>] contexts
  def initialize(contexts:, options:, **)
    super
    @contexts = contexts
    @chart = options.fetch(:chart, 'bar')
    @path = options.fetch(:path, GRAPH_PATH)
  end

  # @param [Hash{ BenchmarkDriver::Job => Hash{ BenchmarkDriver::Context => { BenchmarkDriver::Metric => Float } } }] result
  # @param [Array<BenchmarkDriver::Metric>] metrics
  def bulk_output(job_context_result:, metrics:)
    print "rendering graph..."
    charty = Charty::Plotter.new(:pyplot)

    metric = metrics.first # only one metric is supported for now
    if job_context_result.keys.size == 1
      job = job_context_result.keys.first

      names = job_context_result[job].keys.map(&:name)
      case @chart
      when 'bar'
        values = job_context_result[job].values.map { |result| result.values.fetch(metric) }
        chart = charty.barh do
          series names, values
          ylabel metric.unit
        end
      when 'box'
        values = job_context_result[job].values.map { |result| result.all_values.fetch(metric) }
        chart = charty.box_plot do
          labels names
          data values
          ylabel metric.unit
        end
      else
        raise ArgumentError, "unexpected --output-chart: #{@chart}"
      end
    else
      jobs = job_context_result.keys

      case @chart
      when 'bar'
        values = @contexts.map{|context|
          [
            jobs.map{|job| "#{job.name}(#{context.name})" },
            jobs.map{|job| job_context_result[job][context].values.fetch(metric).round }
          ]
        }
        chart = charty.barh do
          values.each do |value|
            series *value
          end
          ylabel metric.unit
        end
      when 'box'
        raise NotImplementedError, "--output-chart=box is not supported with multiple jobs"
      else
        raise ArgumentError, "unexpected --output-chart: #{@chart}"
      end
    end
    chart.save(@path)
    puts ": #{@path}"
  end

  def with_job(job, &block)
    puts "* #{job.name}..."
    super
  end

  def with_context(context, &block)
    puts "  * #{context.name}..."
    super
  end
end
