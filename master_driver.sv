//  ################################################################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one or more contributor license 
//  agreements. See the NOTICE file distributed with this work for additional information
//  regarding copyright ownership. The ASF licenses this file to you under the Apache License,
//  Version 2.0 (the"License"); you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the 
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
//  either express or implied. See the License for the specific language governing permissions and 
//  limitations under the License.
//
//  ################################################################################################

//  2) Use of Include Guards
//`ifndef _master_driver_INCLUDED_
//`define _master_driver_INCLUDED_

//------------------------------------------------------------------------------------------------//
//  Class: master_driver
//  A driver is written by extending the uvm_driver.uvm_driver is inherited from uvm_component, 
//  Methods and TLM port (seq_item_port) are defined for communication between sequencer and driver.
//  The uvm_driver is a parameterized class and it is parameterized with the type of the request
//  sequence_item and the type of the response sequence_item. 
//------------------------------------------------------------------------------------------------//
class master_driver extends uvm_driver #(master_xtn);


//------------------------------------------------------------------------------------------------//
//  Factory registration is done by passing class name as argument.
//  Factory Method in UVM enables us to register a class, object and variables inside the factory 
//  so that we can override their type (if needed) from the test bench without needing to make any
//  significant change in component structure.
//------------------------------------------------------------------------------------------------//
		`uvm_component_utils(master_driver)

//------------------------------------------------------------------------------------------------//
//  Virtual interface holds the pointer to the Interface.    
//------------------------------------------------------------------------------------------------//
		 virtual uart_if vif;
		 master_agent_config w_cfg;
     env_config env_cfg;

     
     real bit_time;
 
//------------------------------------------------------------------------------------------------//
//  The extern qualifier indicates that the body of the method (its implementation) is to be found 
//  outside the declaration.
//------------------------------------------------------------------------------------------------//
		 extern function new (string name="master_driver", uvm_component parent);
		 extern function void build_phase(uvm_phase phase);
		 extern function void connect_phase(uvm_phase phase);
		 extern task run_phase(uvm_phase phase);

endclass:master_driver


//----------------------------------------New_Constructor-----------------------------------------//
//  The new function is called as class constructor. On calling the new method it allocates the 
//  memory and returns the address to the class handle. For the component class two arguments to be 
//  passed. 
//------------------------------------------------------------------------------------------------//
	function master_driver::new(string name = "master_driver", uvm_component parent);
		super.new(name, parent);
	endfunction:new


//----------------------------------------Build_Phase---------------------------------------------//
//  The build phases are executed at the start of the UVM Testbench simulation and their overall 
//  purpose is to construct, configure and connect the Testbench component hierarchy.
//  All the build phase methods are functions and therefore execute in zero simulation time.
//------------------------------------------------------------------------------------------------//
	function void master_driver::build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(master_agent_config)::get(this,"","master_agent_config",w_cfg))
			`uvm_fatal("CONFIG","Cannot get() w_cfg from uvm_config_db. Have you set() it?")
	endfunction:build_phase


//----------------------------------------Connect_Phase-------------------------------------------//
//  The connect phase is used to make TLM connections between components or to assign handles to 
//  testbench resources. It has to occur after the build method so that Testbench component 
//  hierarchy could be in place and it works from the bottom-up of the hierarchy upwards.
//------------------------------------------------------------------------------------------------//
	function void master_driver::connect_phase(uvm_phase phase);
		vif = w_cfg.vif;
	endfunction:connect_phase


//----------------------------------------Run_Phase-----------------------------------------------//
//  The run phase is used for the stimulus generation and checking activities of the Testbench. 
//  The run phase is implemented as a task, and all uvm_component run tasks are executed in parallel.
//------------------------------------------------------------------------------------------------//
	task master_driver::run_phase(uvm_phase phase);

    //initial condition
			@(negedge vif.reset);
       vif.masterdrv_cb.tx <= 0;
      vif.masterdrv_cb.rx <=0;
      vif.masterdrv_cb.da[8] <= 0;
   


  //-----------------------------------------------------------------------------------------------
  //task:body
  //Defining the time period required for each cycle transmission
  //-----------------------------------------------------------------------------------------------
   bit_time = (1/(env_cfg.buard_rate));

      //for tx
      forever
				  begin
            	seq_item_port.get_next_item(req);
               vif.masterdrv_cb.tx=1'b0;
                 #(bit_time);
					          for(int i=0;i<8;i++)
                    begin
                     vif.masterdrv_cb.tx = req.da[i];
                     #(bit_time);
                     vif.masterdrv_cb.tx=1'b1;
	                   end
                     #(bit_time);
             		seq_item_port.item_done();
					end 

	endtask:run_phase

