require 'rest-client'
require 'rubygems'
require 'json'
require 'active_support'

#Please refer to: http://parter-api-example.readthedocs.org/en/latest/intro.html

module IoasysPayleven
	extend self
		
	#################################################################
	#Getter's and Setter's 							   				#
	#################################################################
	def self.public_key_dev
		@public_key_dev
	end

	def self.public_key_dev=(value)
		@public_key_dev = value
	end

	def self.secret_key_dev
		@secret_key_dev
	end

	def self.secret_key_dev=(value)
		@secret_key_dev = value
	end

	def self.username_dev
		@username_dev
	end

	def self.username_dev=(value)
		@username_dev = value
	end

	def self.password_dev
		@password_dev
	end

	def self.password_dev=(value)
		@password_dev = value
	end

	def self.public_key_prod
		@public_key_prod
	end

	def self.public_key_prod=(value)
		@public_key_prod = value
	end

	def self.secret_key_prod
		@secret_key_prod
	end

	def self.secret_key_prod=(value)
		@secret_key_prod = value
	end

	def self.username_prod
		@username_prod
	end

	def self.username_prod=(value)
		@username_prod = value
	end

	def self.password_prod
		@password_prod
	end

	def self.password_prod=(value)
		@password_prod = value
	end

	def self.prod_env=(value)	#Environment variable		
		if value.is_a?(TrueClass) || value.is_a?(FalseClass)
			@prod_env = value
		end
	end

	def self.prod_env
		@prod_env
	end

	#################################################################


	#################################################################
	#Methods to be used in Code 									#
	#################################################################
	#--
	#________________________________________________________________
	#|Method name: register_card									 |
	#|																 |
	#|Description: Registers user's credit card in given payleven_id |
	#|																 |
	#|Required parameters: 											 |
	#|	payleven_id		=> payleven_id where cc will be registered   |
	#|	cc_number		=> credit card number                        |
	#|	cc_holder		=> credit card holder                        |
	#|	cc_expiration	=> credit card expiration                    | 
	#|	cc_cvv			=> credit card cvv number                    |
	#|	cc_brand		=> credit card brand 				     	 |
	#|																 |
	#|Types:                   										 |
	#|	payleven_id		=> Integer  								 |
	#|	cc_number		=> String (not formated)                     |
	#|	cc_holder		=> String                                    |
	#|	cc_expiration	=> String   			                     | 
	#|	cc_cvv			=> String  				                     |
	#|	cc_brand		=> String (Visa/Master/Discover/Dinners) 	 |
	#|																 |
	#|Example success hash:											 |
	#|	{															 |
	#|		success: true,											 |
	#|		token: "token_string"									 |
	#|		cc_n_strip: "1234"	(card's last four digits)			 |
	#|	}															 |
	#|_______________________________________________________________|
	#++

	def self.register_card(params)
		headers = {:'x-partner-token'=> get_access_token}

		host = get_host 'gateway'
		url  = host + 'partner/createToken'
		#return get_credential 'username'
		begin
			response = RestClient.post(url,params,headers)
			{success: true, token: JSON[response.body]["token"], cc_n_strip: params[:cc_number][params[:cc_number].length - 4, 4]}
		rescue RestClient::ExceptionWithResponse => err
			{success: false, error: JSON[err.response]}
		end
	end
	#--
	#________________________________________________________________
	#|Method name: pay 												 |
	#|																 |
	#|Description: Takes a previously registered credit card and tri-|
	#|	es transfer given value to given payleven_id's bank account. |
	#|																 |
	#|Required parameters: 											 |
	#|	payleven_id				=> payleven_id to receive specified  |
	#| 								value 						     |
	#|	token					=> credit card token previously re-  |
	#|							   gistered at specified payleven_id |
	#|	value					=> Value to be transfered 			 | 
	#|	card_holder_reference 	=> Reference to given user on your db|
	#|	request_id 				=> Reference to this transaction on  |
	#|							   your db 							 |
	#|	cc_brand				=> credit card brand			     |
	#|																 |
	#|Types:                   										 |
	#|	payleven_id				=> Integer  						 |
	#|	token                   => String                       	 |
	#|	value    				=> String                            |
	#|	card_holder_reference 	=> String  			                 | 
	#|	request_id				=> String  				             |
	#|	cc_brand				=> String  (Visa/Master/Discover/	 |
	#|										Dinners)				 |
	#|																 |
	#|Example success hash: 										 |
	#|	{															 |
	#|		:success=>true, 										 |
	#|		:transaction=>{											 |
	#|				:requestId=>"0", #-> request_id sent in params 	 |
	#|				:TransactionID=>"7899891", 						 |
	#|				:Status code=>"6",								 |
	#|				:Message=>"Transacao capturada.",				 |
	#|				:plan=>"123", 									 |
	#|				:forecast_to=>"2015-12-04"						 |
	#|			}													 |
	#|		}														 |
	#|_______________________________________________________________|
	#++

	def self.pay(params)	
		headers = {:'x-partner-token'=> get_access_token}
		
		host = get_host 'gateway'
		url = host + 'partner/processWithToken'
		
		begin
			response = RestClient.post(url,params,headers)
			{success: true, transaction: JSON[response.body]}
		rescue RestClient::ExceptionWithResponse => err
			{success: false, error: JSON[err.response]}
		end
	end

	#####
	def self.send_receipt?(email, tid)
		host = get_host 'gateway'
		url  = host + '/partner/send-receipt'
		data = {email: email, tid: tid}
		
		begin
			response = RestClient.get(url, data)
			true
		rescue RestClient::ExceptionWithResponse => err
			false
		end
	end
	#####

	#--________________________________________________________________
	#|Method name: create_customer 									 |
	#|																 |
	#|Description: Uses given parameters for registration of a new   |
	#|	company. This company will receive a payleven_id to be used  |
	#|	on other requests.											 |
	#|																 |
	#|Required parameters: 											 |
	#|	first_name				=> Customer's first name			 |
	#|	last_name				=> Customer's last name 			 |
	#|	birth_date				=> Customer's date of birth 		 |
	#|	telephone				=> Customer's telephone 			 |
	#|	cpf						=> Customer's cpf 					 |
	#|	merchant_reference		=> Customer's data reference on your |
	#| 							   db 								 |
	#|	email					=> Customer's email 				 |
	#|	gender					=> Customer's gender (M/F) 			 |
	#|	address_state			=> State 							 |
	#|	address_city			=> City 							 |
	#|	address_complement		=> Complement 						 |
	#|	address_postalcode		=> Zip code 						 |
	#|	address_street			=> Street 							 |
	#|	address_number			=> Number 							 |
	#|	address_district		=> District 						 |
	#|	company_name			=> Company's name 					 |
	#|	company_document		=> Company's document 				 |
	#|																 |
	#|Optional parameters: 											 |
	#|	branch 					=> Bank account's branch			 |
	#|	account_number 			=> Bank account number			 	 |
	#|	account_number_digit 	=> Bank account number's digit 		 |
	#|	document_type			=> Individual/Corporate (CPF/CNPJ)	 |
	#|	document_number			=> CPF/CNPJ 						 |
	#|	account_type			=> Checking/Savings 				 |
	#|	account_holder 			=> Account holder's name 			 |
	#|	branch_digit			=> Bank account's branch digit (if 	 |
	#|					   		   specified bank has this informa 	 |
	#| 					   		   tion, this parameter must becomes |
	#|							   required)						 |
	#|																 |
	#|Types:                   										 |
	#|	payleven_id		=> integer  						 		 |
	#|	other_params	=> String				 					 |
	#|																 |
	#|Example success hash: 										 |
	#|	{															 |
	#|		:success=>true, 										 |
	#|		:body=>{											 	 |
	#|				"payleven_id" : "333666"						 |
	#|			}													 |
	#|		}														 |
	#|_______________________________________________________________|
	#++
	def self.create_customer(params)

		public_key = get_key 'public'
		secret_key = get_key 'secret'

		params.each do |field, key| #guarantee that everything that should be an integer is an integer
			if @number_fields.include? field
				params[field] = key.to_i
			end
		end
		params[:timestamp] = DateTime.now
		data = payleven_encoded params#encode string AND build ordered hash to be used in CreateCustomer request
		
		signature_token = get_signature_token(secret_key, data[:payleven_string])
		
		h = ActiveSupport::OrderedHash.new
		h[:token] = signature_token
		h[:access] = public_key
		data[:ordered_hash].each do |field, key|
			h[field] = key
		end

		host = get_host 'panel'
		url = host + "api/customer/create/"

		begin
			response = RestClient.post(url,h)
			{success: true, payleven_id: JSON[response.body]["payleven_id"]}
		rescue RestClient::ExceptionWithResponse => err
			{success: false, error: JSON[err.response]}
		end

	end

		#--
		# Required Params:
		# 	payleven_id = 38618
		# 	merchant_reference = "1845952790"
		# 	bank_id = "341"
		# 	account_holder  JOHN D CARMACK
		# 	branch = 8098
		# 	account_type = checking
		# 	account_number = 00172
		# 	account_number_digit = 3
		# Optional Params:
		# 	document_type = individual
		# 	document_number = 39427952806
		# 	???
		#++
	def self.update_customer(params)
		public_key = get_key 'public'
		secret_key = get_key 'secret'

		params.each do |field, key| #guarantee that everything that should be an integer is an integer
			if @number_fields.include? field
				params[field] = key.to_i
			end
		end
		params[:timestamp] = DateTime.now
		data = payleven_encoded params#encode string AND build ordered hash to be used in CreateCustomer request
		
		signature_token = get_signature_token(secret_key, data[:payleven_string])
		
		h = ActiveSupport::OrderedHash.new
		h[:token] = signature_token
		h[:access] = public_key
		data[:ordered_hash].each do |field, key|
			h[field] = key
		end

		host = get_host 'panel'
		url = host + "api/customer/bank/update/"

		begin
			response = RestClient.post(url,h)
			{success: true, body: JSON[response.body]["message"]}
		rescue RestClient::ExceptionWithResponse => err
			{success: false, error: JSON[err.response]}
		end
	end


	#################################################################


	private

		# Constant variables

		@panel_dev  = 'https://painel-staging.payleven.com.br/'
		@panel_prod = 'https://painel.payleven.com.br/'

		@gateway_dev  = 'http://staging-api.payleven.com.br/'
		@gateway_prod = 'https://v2new-api.payleven.com.br/'

		@minhaconta_dev  = ''#ausente da documentação no momento em que gema foi implementada
		@minhaconta_prod = 'https://minhaconta.payleven.com.br/'

		#List of fields that must be numbers on Access/Secret methods create and update.

		@number_fields = [:document, :telephone, :cellphone, :address_number, :address_postalcode, :branch, :branch_digit, :account_number, :account_number_digit]

		#--
		#Returns which key should be used (dev or prod)
		#++
		def get_key(key)
			if @prod_env
				if key == 'secret'
					@secret_key_prod
				elsif key == 'public'
					@public_key_prod
				end
			else
				if key == 'secret'
					@secret_key_dev
				elsif key == 'public'
					@public_key_dev
				end
			end
		end
		#--
		#Returns which credential should be used (dev or prod)
		#++
		def get_credential(credential)
			if @prod_env
				if credential == 'password'
					@password_prod
				elsif credential == 'username'
					@username_prod
				end
			else
				if credential == 'password'
					@password_dev
				elsif credential == 'username'
					@username_dev					
				end
			end
		end
		#--
		#Returns which host should be used (dev or prod)
		#++
		def get_host(host)
			if host == 'gateway'
				if @prod_env
					@gateway_prod
				else
					@gateway_dev
				end
			elsif host == 'panel'
				if @prod_env
					@panel_prod
				else
					@panel_dev
				end
			elsif host == 'minhaconta'
				if @prod_env
					@minhaconta_prod
				else
					@minhaconta_dev
				end
			end
		end
		#--
		#Get Access token
		#++
		def get_access_token

			host = get_host 'gateway'
			username = get_credential 'username'
			password = get_credential 'password'
			
			url = host + 'partner/authorize'
			#return url
			data = {username: username, password: password}
			response = RestClient.post url,data
			if response.code != 201
				return {success: false, error: JSON[response.body]}
			end
			JSON[response.body]["access_token"]
		end
		#--
		#Encode hash string as specified in payleven documentation
		#++
		def payleven_encoded(h)
			encoded_string = ""
			ordered_hash = ActiveSupport::OrderedHash.new
			
			h.each do |field, key|
				new_field = "entity["+field.to_s+"]"
				encoded_string+= field.to_s + ":" 
				if key.is_a? DateTime
					encoded_string+= key.to_s.gsub("T", " ")[0,19]
					ordered_hash[new_field.to_sym] = key.to_s.gsub("T", " ")[0,19]
				
				elsif not key.is_a? String
					encoded_string+= key.to_s 
					ordered_hash[new_field.to_sym] = key
				
				else
					encoded_string+= key
					ordered_hash[new_field.to_sym] = key
				end
				encoded_string+= ","

			end
			{payleven_string: encoded_string[0, encoded_string.length-1], ordered_hash: ordered_hash}
		end
		#--
		#Get signature token as stated in paylevens documentation (Access/Secret method)
		#++
		def get_signature_token(secret_key, payleven_string)
			sha512 = OpenSSL::Digest.new('sha512')
			sha1 = Digest::SHA1.new
			
			encoded256 = OpenSSL::HMAC.hexdigest(sha512, secret_key, payleven_string)
			sha1.hexdigest encoded256
		end

end
