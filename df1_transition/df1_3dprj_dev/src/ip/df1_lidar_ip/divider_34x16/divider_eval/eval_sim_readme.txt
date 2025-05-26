1. Test environment:
   1) DUT: divider IP core configuration:
      Generation the configuration based on requirement in the IPexpress GUI, the scripts file will be generated under \divider_eval\<user_name>\sim\modelsim(aldec)\scripts
      <user_name>_rtl_se.do: Functional simulation
      <user_name>_synp_se.do: Timing simulation for synplify flow
      If using modelsim to do simulation, in Modelsim GUI, change direcotry to the location and run the two scripts to verify the correctness of the core, otherwise, run the two scripts in aldec GUI.


2. Sequence of operation:
   1)  Asynchronous reset assertion and de-assertion  
   2)  Input samples are given at the input port asserting dvalid_in high. 
   3)  Output data start appearing at the output port dout after IP core latency.
       dvalid_out signal is also asserted indicating output data is valid. 
                          
