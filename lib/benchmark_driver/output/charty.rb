require 'charty'
require 'benchmark_driver'

class BenchmarkDriver::Output::Charty < BenchmarkDriver::BulkOutput
  GRAPH_PATH = 'charty.png'

  # @param [Array<BenchmarkDriver::Metric>] metrics
  # @param [Array<BenchmarkDriver::Job>] jobs
  # @param [Array<BenchmarkDriver::Context>] contexts
  def initialize(contexts:, **)
    super
    @contexts = contexts
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
      values = job_context_result[job].values.map { |result| result.values.fetch(metric) }
      barh = charty.barh do
        series names, values
        ylabel metric.unit
      end
      barh.save("charty.png")
    else
      jobs = job_context_result.keys
      values = @contexts.map{|context|
        [
          jobs.map{|job| "#{job.name}(#{context.name})" },
          jobs.map{|job| job_context_result[job][context].values.fetch(metric).round }
        ]
      }

      barh = charty.barh do
        values.each do |value|
          series *value
        end
        ylabel metric.unit
      end
      barh.save("charty.png")
    end
    puts ": #{GRAPH_PATH}"
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
