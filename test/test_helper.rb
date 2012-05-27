ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'minitest/unit'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  include Wrong

  def get_html(*symbols)
    get *symbols
    @doc = Nokogiri::HTML(@response.body)  #  Because libxml2 + a cute wrapper does NOT suck
  end

  def assert_xpath(*args)  # assert_xpath( [container,] path ) !
    path, container = ([@doc] + args).reverse
    nodes = container.xpath(path)
    node = nodes.first
    assert node, "%s\n\tshould contain %s" % [container.to_xml, path.inspect]

    #  REVIEW  If you use one assert_xpath() to isolate a small div,
    #          and another to find a target in that div, then if
    #          the inner assert_xpath() fails, this assertion will only
    #          splat out that div in its error diagnostic.

    #          It won't splat out the entire page, like Brand X does.

    return nodes.count > 0 ? nodes : node
  end

  def deny_xpath(path)
    assert @doc.xpath(path).empty?
  end

  def activate_partial(partial, locals = {})
    html = render_partial(partial, locals)
    @doc = Nokogiri::HTML(html)
  end

  def render_partial(partial, locals)
    html = @controller.render_to_string(:partial => partial,
                                        :layout => false,
                                        :locals => locals)
  end

  def assert_model_updates model, field, before, after, &block
    assert{ model.send(field) == before }
    block.call
    assert{ model.reload.send(field) == after }
  end

end
