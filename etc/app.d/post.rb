class PCAWGScout
  helpers do
    def saved_studies(user = nil)
      fav = favourite_entities
      fav["Study"] || []
    end

    def user_studies
      Hash.new{|user|
        obj = Object.new
        class << obj
          attr_accessor :user, :saved_studies
          define_method(:include?) do |elem| true end

          def include?(elem)
            true
          end

          def each(&block)
            saved_studies.each do |elem|
              yield(elem)
            end

            PCAWG.all_abbreviations.each do |elem|
              yield(elem)
            end

            #PCAWG.all_meta.each do |elem|
            #  yield("meta=" + elem)
            #end

            #PCAWG.donor_other_cohorts.glob('*').each do |file|
            #  elem = File.basename(file)
            #  yield("other=" + elem)
            #end
          end

          def collect(&block)
            a = []
            each do |elem|
              a << yield(elem)
            end
            a
          end

          def to_a
            a = []
            each do |e|
              a << e
            end
            a
          end

        end

        obj.user = user
        obj.saved_studies = saved_studies(user)
        obj
      }
    end
  end
end


module Study
  alias old_knowledge_base knowledge_base

  def knowledge_base
    kb = old_knowledge_base
    kb.registry.delete_if{|k,v|  %w(mutation_info sample_mutations).include? k.to_s}
    kb
  end

end

module Sinatra
  module RbbtAuth
    module Helpers
      def user
        session[:user] || 'guest'
      end
    end
  end
end

sample_tasks = Sample.tasks.keys.collect{|t| t.to_s}
remote_sample_tasks =  (Sample.remote_tasks || {}).keys.collect{|t| t.to_s}
sample_tasks.delete_if do |task| 
  good = true
  deps = [task]
  while deps.any?
    task = deps.shift
    good = false if task =~ /genomic.*mutation/ or task =~ /vcf/ or task =~ /homozy/ or task =~ /cnv/ or task =~ /^em_/ or task =~ /mutation_info/
    break if not good
    next if Sample.task_dependencies[task.to_sym].nil?
    task_deps = Sample.task_dependencies[task.to_sym].collect do |d|
      case d
      when String,Symbol
        d.to_s
      when Array
        next if d[0] != Sample
        d[1].to_s 
      end
    end
    rest_tasks = task_deps.compact - remote_sample_tasks
    deps.concat rest_tasks
    deps.uniq!
  end
  ! good
end

study_tasks = Study.tasks.keys.collect{|t| t.to_s} - (Study.remote_tasks || {}).keys.collect{|t| t.to_s}
remote_study_tasks =  (Study.remote_tasks || {}).keys.collect{|t| t.to_s}

study_tasks.delete_if do |otask| 
  good = true
  deps = [otask]
  seen = []
  while deps.any?
    task = deps.shift
    good = false if task =~ /genomic.*mutation/ or task =~ /vcf/ or task =~ /homozy/ or task =~ /cnv/ or task =~ /^em_/ or task =~ /mutation_info/
    break if not good
    next if seen.include? task
    seen << task
    next if Study.task_dependencies[task.to_sym].nil? and Sample.task_dependencies[task.to_sym].nil?
    task_deps = (Study.task_dependencies[task.to_sym] || Sample.task_dependencies[task.to_sym]).collect do |d|
      begin
      case d
      when Proc
        d = d.dependency
        raise TryAgain
      when String,Symbol
        d.to_s
      when Array
        next if d[0] != Sample and d[0] != Study
        d[1].to_s 
      end
      rescue TryAgain
        retry
      end
    end
    rest_tasks = task_deps.compact - remote_study_tasks - remote_sample_tasks
    deps.concat rest_tasks
    deps.uniq!
  end
  ! good
end

sample_tasks.concat remote_sample_tasks
sample_tasks.each do |task|
  Sample.export task.to_sym
end

study_tasks.concat remote_study_tasks
study_tasks.each do |task|
  Study.export task.to_sym
end
