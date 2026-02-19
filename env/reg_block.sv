///Control Register Class
//Define class and register fields
class ctl_reg extends uvm_reg;
	`uvm_object_utils(ctl_reg)
	rand uvm_reg_field start;
	rand uvm_reg_field operation;
 	rand uvm_reg_field reserved;
	rand uvm_reg_field id;
//Fctory Register


//Constructor
	function new(string name = "ctl_reg");
		super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

// Build all register field objects
  virtual function void build();
	start      = uvm_reg_field::type_id::create("start");
	operation  = uvm_reg_field::type_id::create("operation");
	reserved   = uvm_reg_field::type_id::create("reserved");
	id         = uvm_reg_field::type_id::create("id");

 //Field configuration(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
	start.configure(this, 1, 0, "WO", 1, 1'h0, 1, 1, 1);
	operation.configure(this, 2, 1, "WO", 0, 2'h0, 1, 1, 1);
	reserved.configure(this, 5, 3, "WO", 0, 5'h0, 1, 1, 1);
	id.configure(this, 8, 8, "WO", 0, 8'h0, 1, 1, 1);
	reserved.configure(this, 16, 16, "WO", 0,16'h0, 1, 1, 1);

//For backdoor access
	add_hdl_path_slice(.name("start_bit_pos"),.offset(0),.size(1));
	add_hdl_path_slice(.name("id_out"),.offset(8),.size(8));
	add_hdl_path_slice(.name("op_out"),.offset(1),.size(2));
  endfunction
endclass

/////////////////////////////////////////////////////////////////////////////////////

/////Data0 Register Class
//Define class and register fields
class data0_reg extends uvm_reg;
//Fctory Register
	`uvm_object_utils(data0_reg)

	rand uvm_reg_field data0;
	rand uvm_reg_field reserved;
//Constructor
	function new(string name = "data0_reg");
		super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

// Build all register field objects
  virtual function void build();
 	data0       = uvm_reg_field::type_id::create("data0"); 
 	reserved   = uvm_reg_field::type_id::create("reserved");

 //Field configuration(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
	data0.configure(this, 16, 0, "WO", 1, 16'h0, 1, 1, 1);
	reserved.configure(this, 16, 16, "WO", 0, 16'h0, 1, 1, 1);

 //For backdorr access
	add_hdl_path_slice( .name("data_0_out"), .offset(0), .size(16));
  endfunction
endclass

///////////////////////////////////////////////////////////////////////////////////

/////Data1 Register Class
//Define class and register fields
class data1_reg extends uvm_reg;
//Fctory Register
	`uvm_object_utils(data1_reg)
	rand uvm_reg_field data1;
	rand uvm_reg_field reserved;

//Constructor
	function new(string name = "data1_reg");
		super.new(name, 16, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

// Build all register field objects
  virtual function void build();
 	data1      = uvm_reg_field::type_id::create("data1"); 
 	reserved   = uvm_reg_field::type_id::create("reserved");

 //Field configuration(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
	data1.configure(this, 16, 0, "WO", 1, 16'h0, 1, 1, 1);

	//For backdorr access
	add_hdl_path_slice( .name("data_1_out"), .offset(0), .size(16));
  endfunction
endclass


//////////////////////////////////////////////////////////////////////////////////

/////Result Register Class
//Define class and register fields
class result_reg extends uvm_reg;
	//Fctory Register
	`uvm_object_utils(result_reg)
	rand uvm_reg_field result;
	rand uvm_reg_field reserved;
//Constructor
	function new(string name = "result_reg");
		super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

// Build all register field objects
  virtual function void build();
 	result     = uvm_reg_field::type_id::create("result"); 
        reserved   = uvm_reg_field::type_id::create("reserved");
        
 //Field configuration(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
	this.result.configure(this, 25, 0, "RO", 0, 25'h0, 1, 1, 1);
	reserved.configure(this, 7, 25, "WO", 0, 7'h0, 1, 1, 1);
  endfunction
endclass

/////////////////////////////////////////////////////////////////////////////////

/////Monitor Register Class
//Define class and register fields
class monitor_reg extends uvm_reg;
	
//Fctory Register
	`uvm_object_utils(monitor_reg)
	
	rand uvm_reg_field monitor;
	rand uvm_reg_field reserved;

//Constructor
	function new(string name = "monitor_reg");
		super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
	endfunction: new

// Build all register field objects
  virtual function void build();
 	monitor    = uvm_reg_field::type_id::create("monitor"); 
	reserved   = uvm_reg_field::type_id::create("reserved");
	
 //Field configuration(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible);
	monitor.configure(this, 2, 0, "RO", 0, 25'h1, 1, 1, 1);//////allagh reset, k fields, k size
	reserved.configure(this, 30, 2, "WO", 0, 30'h0, 1, 1, 1);
  endfunction
endclass



// These registers are grouped together to form a register block called "cfg"
class reg_block extends uvm_reg_block;

`uvm_object_utils(reg_block)

	rand ctl_reg   ctl;      // WO
	rand data0_reg   data0;   // WO
   	rand data1_reg  data1;    // WO
	rand result_reg  result;  //RO
	rand monitor_reg monitor; //RO

	 uvm_reg_map         reg_map;

	function new(string name = "reg_block");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction

  virtual function void build();
//Create map, start memory point = 0, register size = 32bits -> 4bytes.
    this.reg_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);

    this.ctl = ctl_reg::type_id::create("ctl");
    this.ctl.configure(this, null, "");
    this.ctl.build();
    this.reg_map.add_reg(this.ctl, `UVM_REG_ADDR_WIDTH'h0, "WO", 0);//Αλλάζει ανα 4 το address αφου είναι 4 bytes κάθε reg

    this.data0 = data0_reg::type_id::create("data0");
    this.data0.configure(this, null, "");
    this.data0.build();
    this.reg_map.add_reg(this.data0, `UVM_REG_ADDR_WIDTH'h1, "WO", 0);

    this.data1 = data1_reg::type_id::create("data1");
    this.data1.configure(this, null, "");
    this.data1.build();
    this.reg_map.add_reg(this.data1, `UVM_REG_ADDR_WIDTH'h2, "WO", 0);

    this.result = result_reg::type_id::create("result");
    this.result.configure(this, null, "");
    this.result.build();
    this.reg_map.add_reg(this.result, `UVM_REG_ADDR_WIDTH'h3, "RO", 0);

 	 this.monitor = monitor_reg::type_id::create("monitor");
    this.monitor.configure(this, null, "");
    this.monitor.build();
    this.reg_map.add_reg(this.monitor, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);

   default_map.set_check_on_read(0);
   lock_model();

  endfunction
endclass

