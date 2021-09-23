
/* This header file describes the CSR Slave for the slavereg_comp component */

#ifndef __SLAVEREG_COMP_CSR_REGS_H__
#define __SLAVEREG_COMP_CSR_REGS_H__



/******************************************************************************/
/* Memory Map Summary                                                         */
/******************************************************************************/

/*
  Register  | Access  |   Register Contents      | Description
  Address   |         |      (64-bits)           | 
------------|---------|--------------------------|-----------------------------
        0x0 |       R |         {reserved[62:0], |     Read the busy status of
            |         |               busy[0:0]} |               the component
            |         |                          |  0 - the component is ready
            |         |                          |       to accept a new start
            |         |                          |    1 - the component cannot
            |         |                          |          accept a new start
------------|---------|--------------------------|-----------------------------
        0x8 |       W |         {reserved[62:0], |  Write 1 to signal start to
            |         |              start[0:0]} |               the component
------------|---------|--------------------------|-----------------------------
       0x10 |     R/W |         {reserved[62:0], |      0 - Disable interrupt,
            |         |   interrupt_enable[0:0]} |        1 - Enable interrupt
------------|---------|--------------------------|-----------------------------
       0x18 |  R/Wclr |         {reserved[61:0], | Signals component completion
            |         |               done[0:0], |       done is read-only and
            |         |   interrupt_status[0:0]} | interrupt_status is write 1
            |         |                          |                    to clear
------------|---------|--------------------------|-----------------------------
       0x20 |       R |       {returndata[63:0]} |        Return data (0 of 2)
------------|---------|--------------------------|-----------------------------
       0x28 |       R |     {returndata[127:64]} |        Return data (1 of 2)
------------|---------|--------------------------|-----------------------------
       0x30 |     R/W |         {memdata1[63:0]} |           Argument memdata1
------------|---------|--------------------------|-----------------------------
       0x38 |     R/W |         {memdata2[63:0]} |           Argument memdata2
------------|---------|--------------------------|-----------------------------
       0x40 |     R/W |         {memdata3[63:0]} |           Argument memdata3
------------|---------|--------------------------|-----------------------------
       0x48 |     R/W |         {reserved[31:0], |              Argument index
            |         |             index[31:0]} |                            
------------|---------|--------------------------|-----------------------------
       0x50 |     R/W |         {reserved[31:0], |              Argument value
            |         |             value[31:0]} |                            

NOTE: Writes to reserved bits will be ignored and reads from reserved
      bits will return undefined values.
*/


/******************************************************************************/
/* Register Address Macros                                                    */
/******************************************************************************/

/* Byte Addresses */
#define SLAVEREG_COMP_CSR_BUSY_REG (0x0)
#define SLAVEREG_COMP_CSR_START_REG (0x8)
#define SLAVEREG_COMP_CSR_INTERRUPT_ENABLE_REG (0x10)
#define SLAVEREG_COMP_CSR_INTERRUPT_STATUS_REG (0x18)
#define SLAVEREG_COMP_CSR_RETURNDATA_0_REG (0x20)
#define SLAVEREG_COMP_CSR_RETURNDATA_1_REG (0x28)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA1_REG (0x30)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA2_REG (0x38)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA3_REG (0x40)
#define SLAVEREG_COMP_CSR_ARG_INDEX_REG (0x48)
#define SLAVEREG_COMP_CSR_ARG_VALUE_REG (0x50)

/* Argument Sizes (bytes) */
#define SLAVEREG_COMP_CSR_RETURNDATA_0_SIZE (8)
#define SLAVEREG_COMP_CSR_RETURNDATA_1_SIZE (8)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA1_SIZE (8)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA2_SIZE (8)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA3_SIZE (8)
#define SLAVEREG_COMP_CSR_ARG_INDEX_SIZE (4)
#define SLAVEREG_COMP_CSR_ARG_VALUE_SIZE (4)

/* Argument Masks */
#define SLAVEREG_COMP_CSR_RETURNDATA_0_MASK (0xffffffffffffffffULL)
#define SLAVEREG_COMP_CSR_RETURNDATA_1_MASK (0xffffffffffffffffULL)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA1_MASK (0xffffffffffffffffULL)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA2_MASK (0xffffffffffffffffULL)
#define SLAVEREG_COMP_CSR_ARG_MEMDATA3_MASK (0xffffffffffffffffULL)
#define SLAVEREG_COMP_CSR_ARG_INDEX_MASK (0xffffffff)
#define SLAVEREG_COMP_CSR_ARG_VALUE_MASK (0xffffffff)

/* Status/Control Masks */
#define SLAVEREG_COMP_CSR_BUSY_MASK   (1<<0)
#define SLAVEREG_COMP_CSR_BUSY_OFFSET (0)

#define SLAVEREG_COMP_CSR_START_MASK   (1<<0)
#define SLAVEREG_COMP_CSR_START_OFFSET (0)

#define SLAVEREG_COMP_CSR_INTERRUPT_ENABLE_MASK   (1<<0)
#define SLAVEREG_COMP_CSR_INTERRUPT_ENABLE_OFFSET (0)

#define SLAVEREG_COMP_CSR_INTERRUPT_STATUS_MASK   (1<<0)
#define SLAVEREG_COMP_CSR_INTERRUPT_STATUS_OFFSET (0)
#define SLAVEREG_COMP_CSR_DONE_MASK   (1<<1)
#define SLAVEREG_COMP_CSR_DONE_OFFSET (1)


#endif /* __SLAVEREG_COMP_CSR_REGS_H__ */



