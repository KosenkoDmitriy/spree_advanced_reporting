class Spree::AdvancedReport::SegmentReport::Customer < Spree::AdvancedReport::SegmentReport
  def name
    'Customers'
  end

  def description
    'Customer info over a specified time span with specified products.
    Orders: The orders that occurred in the specified time span.
    Total Orders: All order for the customer.
    New Customer: If the customer made their first order within the specified time span.'
  end

  def initialize(params)
    super(params)

    orders.each do |order|
      if order.user
        data[order.user.id] ||= {
            :email => order.user.email,
            :revenue => 0,
            :units => 0,
            :total_orders => 0,
            :order_count => 0
        }
        data[order.user.id][:revenue] += revenue(order)
        data[order.user.id][:units] += units(order)
        data[order.user.id][:order_count] += 1

      end
    end

    all_orders = Spree::Order.all

    all_orders.select do |allOrder|
      if allOrder.user
        if data[allOrder.user.id].present?
          data[allOrder.user.id][:total_orders] += 1
        end
      end
    end

    self.ruportdata = Table(%w[email Units Revenue Orders total_orders new_customer])
    data.inject({}) { |h, (k, v)| h[k] = v[:revenue]; h }.sort { |a, b| a[1] <=> b [1] }.each do |k, v|
      if data[k][:units] > 0
        ruportdata << {'email' => data[k][:email], 'Units' => data[k][:units], 'Revenue' => data[k][:revenue], 'Orders' => data[k][:order_count], 'total_orders' => data[k][:total_orders], 'new_customer' => newCustomer?(data, k)}
      end
    end
    ruportdata.replace_column('Revenue') { |r| '$%0.2f' % r.Revenue }
    ruportdata.rename_column('email', 'Customer Email')
    ruportdata.rename_column('new_customer', 'New Customer')
    ruportdata.rename_column('total_orders', 'Total Orders')
  end

  private
  def newCustomer?(data, key)
    data[key][:order_count] == data[key][:total_orders] ? 'New' : 'Returning'
  end
end
