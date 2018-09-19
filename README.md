# EZFulfill
Ruby application for interfacing with the Shopify API. Takes a .csv file as input, and fulfills orders on the user's Shopify store according to SKU and quantity. This allowed the Boring Company to easily update all of their orders for flamethrowers and fire extinguishers after the sales had closed. 


The notes in this project are a history of the projects development process. We initially wanted to use a large web framework like Django, however when we began exploring our options we found that a private Shopify application did not need such a large framework or so many tools.

Since Shopify's REST API is written in Ruby, it was easier to write the project native to it, and create a simpler application. Code quality is low, but the project needed to be completed very quickly and does not need to be updated or immediately reused. I wrote most of the updater portion, while my collaborator wrote most of the gui portion. 
