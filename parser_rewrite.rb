require 'csv'
require 'httparty'
require 'json'
require 'pp'
class ClientController 
    @@API_KEY = '5d048885226ca5b1118d86a09f23b71b'
    @@API_SECRET = 'e0f454e8b0fe3cebb073a19cf151e317'
    @@SHOP_ADMIN = 'generator-rack.myshopify.com/admin'

    attr_reader :base_uri
    attr_reader :update_list

    def initialize(hashes = [])
        @base_uri = "https://#{@@API_KEY}:#{@@API_SECRET}@#{@@SHOP_ADMIN}"
    end

    def construct_resource_uri(resource_table, resource = "", destination = "")
        uri = [@base_uri, resource_table, resource].join('/')

        if destination.empty? 
            resource_uri = uri[0..-2] + '.json'
        else
            resource_uri = uri + "/#{destination}.json"
        end
    end

	def get_resource_table(target_uri)
        response = HTTParty.get(target_uri)
        data = response.body.to_s
        resource_hash = JSON.parse data
        return resource_hash
    end

    def get_all_keys_for_resource(hash_resource, key, search_list)
        val_list = [key]
        resource_name = hash_resource.keys()[0].to_s.tr("[]", "")
        for h in hash_resource[resource_name]
            if search_list.include? h["name"]
                val_list.push(h[key])
            end
        end
        return val_list
    end

    def check_is_writable(resource_id)
        return true
    end

    def build_update_pathways(resource_table, resource_ids)
        resource_is_writable = self.check_is_writable(resource_ids[0])
        path_list = []
        for resource_id in resource_ids
            path_list.push(self.construct_resource_uri(resource_table, resource_id, "fulfillments"))
        end
        return path_list
    end
end

class OrderUpdate
    attr_accessor :payload
    attr_accessor :destination

    def initialize(json_payload, dest)
        @payload = json_payload
        @destination = dest
    end
end


def find_shop_order_by_name(name, shop_orders_list)
    for order in shop_orders_list
        if order["name"].include? name
            return order
        end
    end
    return 0
end

def get_shop_item_qty_by_sku(sku, order_basket)
    
    pp order_basket
    
    for item in order_basket
        if item["sku"] == sku
            return item["quantity"]
        end
    end
    return 0
end

def quantity_mismatch(flmthrwr_amt, extngshr_amt, shop_order_basket)
        
    shop_flmthrwr_amt = get_shop_item_qty_by_sku("200", shop_order_basket)
    shop_extngshr_amt = get_shop_item_qty_by_sku("201", shop_order_basket)

    puts   shop_extngshr_amt, flmthrwr_amt
    return [(shop_extngshr_amt - extngshr_amt), (shop_flmthrwr_amt - flmthrwr_amt)]
end

def get_shop_item_id_by_sku(sku, shop_order_basket)
    for item in shop_order_basket
        if item["sku"] == sku
            return item["id"]
        end
    end
    return "not_found"
end

def transform_csv_table(csv_table, matching_orders, shop_orders_list)
    payload_build = []
    for csv_order in csv_table.drop(1)
        payload_shell = []
        if matching_orders.include? csv_order[0]
            shop_order = find_shop_order_by_name(csv_order[0], shop_orders_list)
            check = quantity_mismatch(csv_order[2].to_i,csv_order[3].to_i, shop_order["line_items"])
            if check[0] == 0 and check[1] == 0
                puts "all good!"
                payload_shell.push(shop_order["id"])
                payload_shell.push(get_shop_item_id_by_sku("201", shop_order["line_items"]))
                payload_shell.push(csv_order[3].to_i)
                payload_shell.push(get_shop_item_id_by_sku("200", shop_order["line_items"]))
                payload_shell.push(csv_order[2].to_i)
            end
        end
        payload_build.push(payload_shell)
    end
    return payload_build
end


=begin

f = ClientController.new
orders_uri = f.construct_resource_uri("orders")
#puts orders_uri
orders_hash = f.get_resource_table(orders_uri)
=end


filename = "/nfs/2018/e/egoodale/42/Ruby/generatorexample.csv"
csv_table = CSV.read(filename)
#puts csv_table
#transform_csv_table(csv_table, orders_hash["orders"])

csv_order_names = []
for arr in csv_table.drop(1)
    csv_order_names.push(arr[0])
end
#puts csv_order_names


f = ClientController.new
orders_uri = f.construct_resource_uri("orders")
#puts orders_uri
orders_hash = f.get_resource_table(orders_uri)

store_order_names = []
for order in orders_hash["orders"]
    store_order_names.push(order["name"])
end

matching_orders = []

for matching_order in csv_order_names
    if store_order_names.include? matching_order
        matching_orders.push(matching_order)
    else
        puts "Not an order in the store"
    end
end

#puts matching_orders

payload_build = transform_csv_table(csv_table, matching_orders, orders_hash["orders"])

#puts payload_build

order_id_list = []
payload_build.each do |payload|
    order_id_list.push(payload[0])
end
path_list = f.build_update_pathways("orders", order_id_list)

def generate_fulfillment(payload_build)
    hash_rack = []
    payload_build.each do |payload|
        hash_rack.push(
            "fulfillment" => {
              "order_id" => payload[0],
              "line_items" => [
                  {
                      "id" => payload[1],
                      "quantity" => payload[2]
                  },
                  {
                      "id" => payload[3],
                      "quantity" => payload[4]
                  }
              ]
            }
          )
    end
    return hash_rack
end


json_payloads = generate_fulfillment(payload_build)

order_id_list = []
payload_build.each do |payload|
    order_id_list.push(payload[0])
end
#puts order_id_list
path_list = f.build_update_pathways("orders", order_id_list)

#puts path_list

#path_list.zip(json_payloads).each do |path , payload|
#    puts path, payload
#end

class OrderUpdate
    attr_reader :uri
    attr_reader :payload

    def initialize(uri, payload)
        @uri = uri
        @payload = payload
    end
end


order_update_list = []
    
path_list.zip(json_payloads).each do |path , payload|
    order_update_list.push(OrderUpdate.new(path, payload))
end

#for update in order_update_list
#puts update.destination, update.payload
#end

class LocalUpdate 
    include HTTParty
    attr_reader :call_limit_token
    attr_accessor :updates
    attr_reader :destination

    def initialize(updates)
        @updates = updates
        @call_limit_token = "http_x_shopify_shop_api_call_limit"
    end

    def get_api_call_stack(token)
        puts token
        if token == "39/40"
            true
        end
    end

    def post_updates(wait = 10, cycle = 0.5)
        @updates.each do |update|
            response =  HTTParty.post(update.uri, :headers => {'Content-Type'=>'application/json'}, :body => update.payload.to_json)
            puts response.code
            reduce_rate = get_api_call_stack(response.headers[@call_limit_token])
            if reduce_rate == true
                print "Gotta Wait Too Many Requests"
                sleep(wait)
            else
                sleep(cycle)
            end
        end
    end
end


l = LocalUpdate.new(order_update_list)

#for update in l.updates
#puts update.uri, update.payload
#end
l.post_updates







        
