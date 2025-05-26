#!/usr/local/bin/wish

cd D:/FreeWork/df1_second_round/df1_3dprj_dev/src/ip/df1_lidar_ip/divider_34x16
lappend auto_path "D:/TOOL/LatticeDiamond/diamond/3.13/tcltk/lib/ipwidgets/ispipbuilder/../runproc"
package require runcmd

if [runCmd "\"D:/TOOL/LatticeDiamond/diamond/3.13/ispfpga/bin/nt64/ngdbuild\" -dt -a ecp5u -d LFE5U-45F -p \"D:/TOOL/LatticeDiamond/diamond/3.13/ispfpga/sa5p00/data\" -p \".\" \"divider_34x16.ngo\" \"divider_34x16.ngd\""] {
   return
} else {
   vwait done
   if [checkResult $done] {
    return
   }
}
