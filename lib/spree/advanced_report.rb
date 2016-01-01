module Spree
  class AdvancedReport
    include Ruport
    attr_accessor :orders, :product_text, :date_text, :taxon_text, :ruportdata, :data, :params, :taxon, :product, :product_in_taxon, :unfiltered_params

    def name
      'Base Advanced Report'
    end

    def description
      'Base Advanced Report'
    end

    def initialize(params)
      self.params = params
      self.data = {}
      self.ruportdata = {}
      self.unfiltered_params = params[:search].blank? ? {} : params[:search].clone

      params[:search] ||= {}
      if params[:search][:completed_at_gt].blank?
        if (Order.count > 0) && Order.minimum(:completed_at)
          params[:search][:completed_at_gt] = Order.minimum(:completed_at).beginning_of_day
        end
      else
        params[:search][:completed_at_gt] = begin
                                              Time.zone.parse(params[:search][:completed_at_gt]).beginning_of_day
                                            rescue
                                              ''
                                            end
      end
      if params[:search][:completed_at_lt].blank?
        if (Order.count > 0) && Order.maximum(:completed_at)
          params[:search][:completed_at_lt] = Order.maximum(:completed_at).end_of_day
        end
      else
        params[:search][:completed_at_lt] = begin
                                              Time.zone.parse(params[:search][:completed_at_lt]).end_of_day
                                            rescue
                                              ''
                                            end
      end

      params[:search][:completed_at_not_null] = true
      params[:search][:state_not_eq] = 'canceled'

      search = Order.search(params[:search])
      # self.orders = search.state_does_not_equal('canceled')
      self.orders = search.result

      self.product_in_taxon = true
      if params[:advanced_reporting]
        if params[:advanced_reporting][:taxon_id] && params[:advanced_reporting][:taxon_id] != ''
          self.taxon = Taxon.find(params[:advanced_reporting][:taxon_id])
        end
        if params[:advanced_reporting][:product_id] && params[:advanced_reporting][:product_id] != ''
          self.product = Product.find(params[:advanced_reporting][:product_id])
        end
      end
      if taxon && product && !product.taxons.include?(taxon)
        self.product_in_taxon = false
      end

      self.product_text = "<label>Product:</label> #{product.name}" if product
      self.taxon_text = "<label>Taxon:</label> #{taxon.name}" if taxon

      # Above searchlogic date settings
      self.date_text = 'Date Range:'
      if unfiltered_params
        if unfiltered_params[:completed_at_gt] != '' && unfiltered_params[:completed_at_lt] != ''
          self.date_text += " From #{unfiltered_params[:completed_at_gt]} to #{unfiltered_params[:completed_at_lt]}"
        elsif unfiltered_params[:completed_at_gt] != ''
          self.date_text += " After #{unfiltered_params[:completed_at_gt]}"
        elsif unfiltered_params[:completed_at_lt] != ''
          self.date_text += " Before #{unfiltered_params[:completed_at_lt]}"
        else
          self.date_text += ' All'
        end
      else
        self.date_text += ' All'
      end
    end

    def download_url(base, format, report_type = nil)
      elements = []
      params[:advanced_reporting] ||= {}
      params[:advanced_reporting]['report_type'] = report_type if report_type
      if params
        [:search, :advanced_reporting].each do |type|
          if params[type]
            params[type].each { |k, v| elements << "#{type}[#{k}]=#{v}" }
          end
        end
      end
      base.gsub!(/^\/\//, '/')
      base + '.' + format + '?' + elements.join('&')
    end

    def revenue(order)
      rev = order.item_total
      if !product.nil? && product_in_taxon
        rev = order.line_items.select { |li| li.product == product }.inject(0) { |a, b| a += b.quantity * b.price }
      elsif !taxon.nil?
        rev = order.line_items.select { |li| li.product && li.product.taxons.include?(taxon) }.inject(0) { |a, b| a += b.quantity * b.price }
      end
      product_in_taxon ? rev : 0
    end

    def profit(order)
      profit = order.line_items.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price.to_f) * li.quantity }
      if !product.nil? && product_in_taxon
        profit = order.line_items.select { |li| li.product == product }.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price.to_f) * li.quantity }
      elsif !taxon.nil?
        profit = order.line_items.select { |li| li.product && li.product.taxons.include?(taxon) }.inject(0) { |profit, li| profit + (li.variant.price - li.variant.cost_price.to_f) * li.quantity }
      end
      product_in_taxon ? profit : 0
    end

    def units(order)
      units = order.line_items.sum(:quantity)
      if !product.nil? && product_in_taxon
        units = order.line_items.select { |li| li.product == product }.inject(0) { |a, b| a += b.quantity }
      elsif !taxon.nil?
        units = order.line_items.select { |li| li.product && li.product.taxons.include?(taxon) }.inject(0) { |a, b| a += b.quantity }
      end
      product_in_taxon ? units : 0
    end

    def order_count(_order)
      product_in_taxon ? 1 : 0
    end
  end
end
