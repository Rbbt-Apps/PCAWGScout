class EntityGraph
  attr_accessor :entities, :associations, :rules, :aes_rules

  def initialize
    @entities = {}
    @associations = {}
    @rules = []
    @aes_rules = []
  end

  def add_rule(rule)
    @rules.push(rule)
  end

  def add_aes_rule(rule)
    @aes_rules.push(rule)
  end

  def add_entities(entities, type = nil)                                                   
    type ||= entities.base_entity.to_s if entities.respond_to? :base_entity
    @entities[type] ||= {}
    @entities[type][:codes] ||= []
    @entities[type][:codes] += entities.to_a
    @entities[type][:codes].uniq!
    @entities[type][:info] = entities.info if entities.respond_to? :info
  end                        

  def add_associations(associations, database = nil)
    database ||= associations.database.to_s if associations.respond_to? :database
    @associations[database] ||= {}
    @associations[database][:codes] = associations.to_a
    @associations[database][:info] = associations.info if associations.respond_to? :info
    if AssociationItem === associations
      add_entities associations.target_entity, associations.target_entity_type
      add_entities associations.source_entity, associations.source_entity_type
    end
  end

  def model
    model = {}
    model[:entities] = @entities
    model[:associations] = @associations
    model[:rules] = @rules
    model[:aes_rules] = @aes_rules
    model
  end
end
