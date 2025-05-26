`define MR						16'h0000
/*Gateway IP Register address*/
`define GAR0					16'h0001
`define GAR1					16'h0002
`define GAR2					16'h0003
`define GAR3					16'h0004
/*Subnet mask Register address*/
`define SUBR0					16'h0005
`define SUBR1					16'h0006
`define SUBR2					16'h0007
`define SUBR3					16'h0008
/*Source MAC Register address*/
`define SHAR0					16'h0009
`define SHAR1					16'h000a
`define SHAR2					16'h000b
`define SHAR3					16'h000c
`define SHAR4					16'h000d
`define SHAR5					16'h000e
/*Source IP Register address*/
`define SIPR0					16'h000f
`define SIPR1					16'h0010
`define SIPR2					16'h0011
`define SIPR3					16'h0012
/*PHY Configuration Register*/
`define PHYCFG					16'h002e

/*Socket Mode register address*/
`define Sn_MR					16'h0000
/*Socket Command register address*/
`define Sn_CR					16'h0001
/*Socket Interrupt register address*/
`define Sn_IR					16'h0002
/*Socket Status register address*/
`define Sn_SR					16'h0003
/*Socket Source port register address*/
`define Sn_PORT0				16'h0004
`define Sn_PORT1				16'h0005
/*Socket Destination MAC register address*/
`define Sn_DHAR0				16'h0006
`define Sn_DHAR1				16'h0007
`define Sn_DHAR2				16'h0008
`define Sn_DHAR3				16'h0009
`define Sn_DHAR4				16'h000a
`define Sn_DHAR5				16'h000b
/*Socket Destination IP register address*/
`define Sn_DIPR0				16'h000c
`define Sn_DIPR1				16'h000d
`define Sn_DIPR2				16'h000e
`define Sn_DIPR3				16'h000f
/*Socket Destination port register address*/
`define Sn_DPORT0				16'h0010
`define Sn_DPORT1				16'h0011
/*Socket Maximum Segment register address*/
`define Sn_MSSR0				16'h0012
`define Sn_MSSR1				16'h0013


/*Socket Receive Buffer size reigster address*/
`define Sn_RXMEM_SIZE		16'h001e
/*Socket Transmit Buffer size reigster address*/
`define Sn_TXMEM_SIZE		16'h001f
/*Socket TX Free register address*/
`define Sn_TX_FSR0			16'h0020
`define Sn_TX_FSR1			16'h0021
/*Socket TX Read Pointer address*/
`define Sn_TX_RD0				16'h0022
`define Sn_TX_RD1				16'h0023
/*Socket TX Write Pointer address*/
`define Sn_TX_WR0				16'h0024
`define Sn_TX_WR1				16'h0025
/*Socket RX Receive size register address*/
`define Sn_RX_RSR0			16'h0026
`define Sn_RX_RSR1			16'h0027
/*Socket RX Read Pointer address*/
`define Sn_RX_RD0				16'h0028
`define Sn_RX_RD1				16'h0029
/*Socket RX Write Pointer address*/
`define Sn_RX_WR0				16'h002a
`define Sn_RX_WR1				16'h002b

/*Keep alive timer register address*/
`define Sn_KPALVTR			16'h002f

/*retry timer register address*/
`define Sn_RTR0			16'h0019
`define Sn_RTR1			16'h001A

`define Sn_RCR			16'h001B
