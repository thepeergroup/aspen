class AbstractRenderer

  attr_reader :statements, :environment

  def initialize(statements, environment = {})
    @statements = statements
    @environment = environment
  end

  def render
    raise NotImplementedError, "Find me in #{__FILE__}"
  end

  def nodes
    raise NotImplementedError, "Find me in #{__FILE__}"
  end

  def relationships
    raise NotImplementedError, "Find me in #{__FILE__}"
  end

end
