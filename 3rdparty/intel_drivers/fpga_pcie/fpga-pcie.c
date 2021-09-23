/*
 *
 * Copyright (C) 2017 Intel Corporation
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "fpga-pcie.h"
#include "altera-pr-ip-core.h"
#include "fpga-region-controller.h"
#include <linux/debugfs.h>
#include <linux/delay.h>
#include <linux/module.h>
#include <linux/pci.h>

#include <linux/kernel.h>
#include <linux/version.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/errno.h>
#include <asm/uaccess.h>

#include <linux/firmware.h>
#include <linux/fs.h>

#include "fpga-ioctl.h"

#define FIRST_MINOR 0
#define MINOR_CNT 1

static dev_t devt;
static struct class *cl;

#define DRIVER_NAME "fpga-pcie"
static const const char* DRIVER_VERSION  = "1.0";
#define DRIVER_DESCRIPTION "JSCJSC - Driver for PR Reference Design PCIe boards"


/* Forward declarations */
static struct pci_driver fpga_pcie_driver;
static int fpga_pcie_register_driver(void);
static void fpga_pcie_unregister_driver(void);

#if 0
1a:00.0 Class ea00: Altera Corporation Device 5052 (rev 01) (prog-if 01)
        Subsystem: Altera Corporation Device 0001
        Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Interrupt: pin A routed to IRQ 30
        NUMA node: 0
        Region 0: Memory at dffff00000 (64-bit, prefetchable) [size=512]
        Region 2: [virtual] Memory at a0220000 (32-bit, non-prefetchable) [size=8K]
        Region 4: [virtual] Memory at a0200000 (32-bit, non-prefetchable) [size=128K]
        Capabilities: [50] MSI: Enable- Count=1/4 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Capabilities: [78] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [80] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 25.000W
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
                LnkCap: Port #1, Speed 8GT/s, Width x8, ASPM not supported, Exit Latency L0s <4us, L1 <1us
                        ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp+
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 8GT/s, Width x8, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF Not Supported
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
                LnkCtl2: Target Link Speed: 8GT/s, EnterCompliance- SpeedDis-
                         Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete+, EqualizationPhase1+
                         EqualizationPhase2+, EqualizationPhase3+, LinkEqualizationRequest-
        Capabilities: [100 v1] Virtual Channel
                Caps:   LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb:    Fixed- WRR32- WRR64- WRR128-
                Ctrl:   ArbSelect=Fixed
                Status: InProgress-
                VC0:    Caps:   PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb:    Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl:   Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
        Capabilities: [200 v1] Vendor Specific Information: ID=1172 Rev=0 Len=044 <?>
        Capabilities: [300 v1] #19
        Kernel modules: fpga_pcie_mod




/* Define the PCIe device settings to match to */
#define ALTR_PCI_CVP_VENDOR_ID 0x1172
#define ALTR_PCI_CVP_DEVICE_ID 0x5052
#define ALTR_PCI_CVP_CLASSCODE 0xEA0001
#define ALTR_PCI_CVP_SUB_VENDOR_ID 0x1172
#define ALTR_PCI_CVP_SUB_DEVICE_ID 0x0001
#endif

/* Register the device identification for the PCIe bus subsystem */
static struct pci_device_id fpga_pcie_pci_ids[] = {
	{
		PCI_DEVICE_SUB(
			ALTR_PCI_CVP_VENDOR_ID,
			ALTR_PCI_CVP_DEVICE_ID,
			ALTR_PCI_CVP_SUB_VENDOR_ID,
			ALTR_PCI_CVP_SUB_DEVICE_ID )
	},
	{
		.vendor = 0x1172,
		.device = 0x5052,
		.subvendor = PCI_ANY_ID,
		.subdevice = PCI_ANY_ID,
		.class = ( PCI_CLASS_SYSTEM_OTHER << 8 ),
		.class_mask = 0
	},
	{0}
};
MODULE_DEVICE_TABLE(pci, fpga_pcie_pci_ids);




static const char *ST_IDLE = "Idle\n";
static const char *ST_AER_DISABLED = "Upstream AER disabled\n";




struct fdev {
	struct list_head list;
	int (*remove)(struct device *dev);
	struct device dev;
};

struct fpga_drv_entry {
	const char *id;
	const char *prefix;
	int (*probe)(struct device *dev, void __iomem *reg_base);
	int (*remove)(struct device *dev);
};

static u32 get_aer_uerr_mask_reg(struct pci_dev *dev)
{
	u32 reg = 0;
	int pos;

	pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_ERR);

	if (!pos) {
		dev_err(&dev->dev, "failed to find AER extended capability\n");
		return -EIO;
	}

	pci_read_config_dword(dev, pos+PCI_EXP_DEVCAP, &reg);

	pci_read_config_dword(dev, pos+PCI_EXP_DEVCTL, &reg);

	return reg;
}

static void set_aer_uerr_mask_reg(struct pci_dev *dev, u32 val)
{
	int pos;

	pos = pci_find_ext_capability(dev, PCI_EXT_CAP_ID_ERR);

	if (!pos) {
		dev_err(&dev->dev, "failed to find AER extended capability\n");
		return;
	}


	pci_write_config_dword(dev, pos+PCI_EXP_DEVCAP, PCI_ERR_UNC_SURPDN | PCI_ERR_UNC_COMP_TIME | PCI_ERR_UNC_UNSUP);

	pci_write_config_dword(dev, pos+PCI_EXP_DEVCTL, val);
}

static u32 disable_upstream_aer(struct pci_dev *dev,
				struct pci_dev *upstream_dev)
{
	u32 reg = 0;

	if (dev == NULL) {
		pr_err("%s NULL dev\n", __func__);
		return -EINVAL;
	} else if (upstream_dev == NULL) {
		
		dev_err(&dev->dev, "%s NULL upstream_dev\n", __func__);
		return -EINVAL;
	}

	reg = get_aer_uerr_mask_reg(upstream_dev);

	set_aer_uerr_mask_reg(upstream_dev, reg | PCI_ERR_UNC_SURPDN | PCI_ERR_UNC_COMP_TIME | PCI_ERR_UNC_UNSUP);

	return reg;
}

static void fpga_pcie_print_rom(struct fpga_pcie_priv *priv)
{
	struct pci_dev *dev = priv->pci_dev;
	void __iomem *rom_base_addr = priv->bar_addrs[ALTR_PCI_CVP_CONFIG_BAR] +
		    		      ALTR_PCI_CONFIG_ROM_OFFSET;

	int i;

	for (i = 0; i < ALTR_PCI_CONFIG_ROM_LEN; i += 4) {
		dev_info(&dev->dev, "ROM %02x %08x\n", i,
			 readl(rom_base_addr+i));
	}
}

/*
 * USed for after full chip configuration, to ensure the correct speed is reported, and if not,
 * re initialize
 */
static void retrain_device_speed(struct pci_dev *dev, struct pci_dev *upstream)
{
	u16 linkstat, speed, width;
	int pos, upos;
	u16 status_reg, control_reg, link_cap_reg;
	u16 status, control;
	u32 link_cap;
	int training, timeout;

	pos = pci_find_capability(dev, PCI_CAP_ID_EXP);

	if (!pos) {
		dev_err(&dev->dev, "Can't find PCI Express capability!\n");
		return;
	}

	upos = pci_find_capability(upstream, PCI_CAP_ID_EXP);
	status_reg = upos + PCI_EXP_LNKSTA;
	control_reg = upos + PCI_EXP_LNKCTL;
	link_cap_reg = upos + PCI_EXP_LNKCAP;
	pci_read_config_word(upstream, status_reg, &status);
	pci_read_config_word(upstream, control_reg, &control);
	pci_read_config_dword(upstream, link_cap_reg, &link_cap);
	
	
	pci_read_config_word(dev, pos + PCI_EXP_LNKSTA, &linkstat);
	pci_read_config_dword(upstream, link_cap_reg, &link_cap);
	speed = linkstat & PCI_EXP_LNKSTA_CLS;
	width = (linkstat & PCI_EXP_LNKSTA_NLW) >> PCI_EXP_LNKSTA_NLW_SHIFT;
	
	if (speed == PCI_EXP_LNKSTA_CLS_2_5GB) {
		dev_info(&dev->dev, "Link speed is 2.5 GT/s with %d lanes.\n",
			 width);
		dev_info(&dev->dev, "Need to retrain.");
	} else if (speed == PCI_EXP_LNKSTA_CLS_5_0GB) {
		dev_info(&dev->dev, "Link speed is 5.0 GT/s with %d lanes.\n",
			 width);
		if (width == DEV_LINK_WIDTH) {
			dev_info(&dev->dev, "  All is good!\n");
			return;
		} else {
			dev_info(&dev->dev, "  Need to retrain.\n");
		}
	} else if (speed == PCI_EXP_LNKSTA_CLS_8_0GB) {
		dev_info(&dev->dev, "Link speed is 8.0 GT/s with %d lanes.\n",
			 width);
		if (width == DEV_LINK_WIDTH) {
			dev_info(&dev->dev, "  All is good!\n");
			return;
		} else {
			dev_info(&dev->dev, "  Need to retrain.\n");
		}
	} else {
		dev_warn(&dev->dev, "Not sure what's going on. Retraining.\n");
	}
	
		  
	/* Perform the training. */
	training = 1;
	timeout = 0;
	pci_read_config_word(upstream, control_reg, &control);
	pci_write_config_word(upstream, control_reg,
			      control | PCI_EXP_LNKCTL_RL);
	
	while (training && timeout < 50)
	{
		pci_read_config_word (upstream, status_reg, &status);
		training = (status & PCI_EXP_LNKSTA_LT);
		msleep (1); /* 1 ms */
		++timeout;
	}
	if(training)
	{
		 dev_info(&dev->dev, "Error: Link training timed out.\n");
		 dev_info(&dev->dev, "PCIe link not established.\n");
	}
	else
	{
		 dev_info(&dev->dev, "Link training completed in %d ms.\n",
			  timeout);
	}
	 

	/* Verify that it's a 8 GT/s link now */
	pci_read_config_word(dev, pos + PCI_EXP_LNKSTA, &linkstat);
	pci_read_config_dword(upstream, link_cap_reg, &link_cap);
	speed = linkstat & PCI_EXP_LNKSTA_CLS;
	width = (linkstat & PCI_EXP_LNKSTA_NLW) >> PCI_EXP_LNKSTA_NLW_SHIFT;
	
	if(speed == PCI_EXP_LNKSTA_CLS_8_0GB)
	{
		dev_info(&dev->dev, "Link operating at 8 GT/s with %d lanes\n",
			 width);
	}
	else if(speed == PCI_EXP_LNKSTA_CLS_5_0GB)
	{
		dev_info(&dev->dev, "Link operating at 5 GT/s with %d lanes\n",
			 width);
	}
	else
	{
		dev_warn(&dev->dev, "** WARNING: Link training failed.\n");
		dev_warn(&dev->dev, "Link speed is 2.5 GT/s with %d lanes.\n",
			 width);
	}
}

static void fpga_pcie_shutdown_pci(struct pci_dev *dev,
				   struct fpga_pcie_priv *priv)
{
	int i;

	for (i = 0; i < ALTR_PCI_CVP_NUM_BARS; i++) {
		if (priv->bar_addrs[i])
			iounmap(priv->bar_addrs[i]);
	}
	pci_release_regions(dev);
	pci_disable_device(dev);
}
/*
 * Called upon deployment of driver, reads config space of pcie, and maps the memory to virtual
 * addresses
 */
static int fpga_pcie_setup_pci(struct pci_dev *dev, struct fpga_pcie_priv *priv)
{
	static const const char *bar_fmt =
		"BAR[%d] 0x%08lx-0x%08lx (%lu bytes) flags 0x%08lx\n";
	int i, err;
	int pos = 0;


	pci_set_drvdata(dev, priv);

	priv->pci_dev = dev;

	dev_info(&dev->dev,"ID is %d.\n", dev->dev.id);

	priv->pci_upstream_dev = pci_upstream_bridge(dev);

	if (priv->pci_upstream_dev == NULL) {
		dev_err(&dev->dev, "no upstream bridge\n");
		return -EINVAL;
	}

	/* Enable the device. This allows access to the device resources */
	if (pci_enable_device(dev)) {
		dev_err(&dev->dev, "pci_enable_device() failed\n");
		return -EIO;
	}

	/* Make sure that the card is set as a bus master. */
	pci_set_master(dev);

	/* Get some info on the PCI Express (PCI_CAP_ID_EXP) capabilities */
	pos = pci_find_capability(dev, PCI_CAP_ID_EXP);

	/* Read the link status */
	if (pos) {
		unsigned short linkstat = 0;
		int link_speed = 0;
		int link_width = 0;

		pci_read_config_word(dev, pos + PCI_EXP_LNKSTA, &linkstat);

		link_speed = linkstat & PCI_EXP_LNKSTA_CLS;
		link_width =
		    (linkstat & PCI_EXP_LNKSTA_NLW) >> PCI_EXP_LNKSTA_NLW_SHIFT;

		if (link_speed == PCI_EXP_LNKSTA_CLS_2_5GB) {
			dev_info(
			    &dev->dev,
			    "Link speed is 2.5 GT/s with %d lanes.\n",
			    link_width);
		} else if (link_speed == PCI_EXP_LNKSTA_CLS_5_0GB) {
			dev_info(
			    &dev->dev,
			    "Link speed is 5.0 GT/s with %d lanes.\n",
			    link_width);
		} else if (link_speed == PCI_EXP_LNKSTA_CLS_8_0GB) {
			dev_info(
			    &dev->dev,
			    "Link speed is 8.0 GT/s with %d lanes.\n",
			    link_width);
		}
	}

	if (pci_request_regions(dev, DRIVER_NAME)) {
		dev_err(&dev->dev, "Failed to request regions");
		pci_disable_device(dev);
		return -EIO;
	}

	for (i = 0; i < ALTR_PCI_CVP_NUM_BARS; i++) {
		/* BARs can return 0 meaning unused */
		unsigned long bar_start = pci_resource_start(dev, i);

		if (bar_start) {
			unsigned long bar_end =
			    pci_resource_end(dev, i);
			unsigned long bar_flags =
			    pci_resource_flags(dev, i);

			dev_info(&dev->dev, bar_fmt,
				 i, bar_start, bar_end,
				 (bar_end - bar_start + 1), bar_flags);
			priv->bar_addrs[i] = pci_ioremap_bar(dev, i);
			if (!priv->bar_addrs[i]) {
				dev_err(&dev->dev,
					"Failed to remap BAR[%d]\n", i);
				err = -EIO;
				goto fail_pci_enable_device;
			}

		} else {
			dev_info(&dev->dev, "BAR[%d] UNUSED\n", i);
		}
	}
	
	//Map address of PR IP
	priv->reg_base = priv->bar_addrs[ALTR_PCI_CVP_CONFIG_BAR] + ALTR_PR_IP_OFFSET;

	return 0;

fail_pci_enable_device:

	fpga_pcie_shutdown_pci(dev, priv);
	
	return err;

}

/**
 * fpga_mgr_buf_load - load fpga from image in buffer
 * @mgr:	fpga manager
 * @info:	fpga image specific information
 * @buf:	buffer contain fpga image
 * @count:	byte count of buf
 *
 * Step the low level fpga manager through the device-specific steps of getting
 * an FPGA ready to be configured, writing the image to it, then doing whatever
 * post-configuration steps necessary.  This code assumes the caller got the
 * mgr pointer from of_fpga_mgr_get() and checked that it is not an error code.
 *
 * Return: 0 on success, negative error code otherwise.
 */
int fpga_config_buf_load(struct fpga_pcie_priv *priv, int config_timeout, struct file *fp)
{
	struct device *dev = &(priv->pci_dev->dev);
	int ret;
	char buf[1024];

	ret = kernel_read(fp, 0, buf, 1024);

	if (ret != 1024)
	{
		dev_err(dev, "Something wrong with file\n");
		return 0;
	}


	/*
	 * Call the low level driver's write_init function.  This will do the
	 * device-specific things to get the FPGA into the state where it is
	 * ready to receive an FPGA image.
	 */
	priv->config_state = FPGA_CONFIG_STATE_WRITE_INIT;
	dev_info(dev, "Calling write_init");
	ret = alt_pr_ip_write_init(priv, buf, 1024);
	dev_info(dev, "Done Calling write_init");

	if (ret) {
		dev_err(dev, "Error preparing FPGA for writing\n");
		priv->config_state = FPGA_CONFIG_STATE_WRITE_INIT_ERR;
		return ret;
	}

	/*
	 * Write the FPGA image to the FPGA.
	 */
	priv->config_state = FPGA_CONFIG_STATE_WRITE;
	dev_info(dev, "Calling write");
	ret = alt_pr_ip_fpga_write(priv, fp);
	dev_info(dev, "Done Calling write");
	if (ret) {
		dev_err(dev, "Error while writing image data to FPGA\n");
		priv->config_state = FPGA_CONFIG_STATE_WRITE_ERR;
		return ret;
	}

	/*
	 * After all the FPGA image has been written, do the device specific
	 * steps to finish and set the FPGA into operating mode.
	 */
	priv->config_state = FPGA_CONFIG_STATE_WRITE_COMPLETE;
	dev_info(dev, "Calling write_complete");
	ret = alt_pr_ip_fpga_write_complete(priv, config_timeout);
	dev_info(dev, "Done Calling write_complete");
	if (ret) {
		dev_err(dev, "Error after writing image data to FPGA\n");
		priv->config_state = FPGA_CONFIG_STATE_WRITE_COMPLETE_ERR;
		return ret;
	}
	priv->config_state = FPGA_CONFIG_STATE_OPERATING;

	return 0;
}



/*
 * All user mode interactions with driver pass through this ioctl function.
 * User mode program will pass commands to this function in order to active specifc subroutines.
 *
 * Returns 0 on success.
 */ 
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,35))
static int my_ioctl(struct inode *i, struct file *f, unsigned int cmd, unsigned long arg)
#else
static long my_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
#endif
{

	pr_arg_t pr_args;
	struct fpga_pcie_priv *priv = (struct fpga_pcie_priv *)f->private_data;
	struct device *dev = &(priv->pci_dev->dev);
	int offset, data;
	rw_arg_t rw_args;
	struct file *fp;
	int result = 0;
pr_info( "my_ioctl(): JSC-Debug: cmd=0x%8.8x [%d]", cmd, cmd );
	switch (cmd)
	{
		case FPGA_DEBUG_PRINT_ROM:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_DEBUG_PRINT_ROM:" );
			fpga_pcie_print_rom(priv);
			break;
		case FPGA_DISABLE_UPSTREAM_AER:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_DISABLE_UPSTREAM_AER:" );
			dev_info(dev, "Preparing to disable upstream AER\n");
			if (priv->state == ST_AER_DISABLED) {
				dev_info(dev, "Upstream AER already disabled\n");
			}
			else {		
				priv->aer_uerr_mask_reg = 
					disable_upstream_aer(priv->pci_dev,
						     priv->pci_upstream_dev);

				dev_info(dev, "%s aer is %x\n", __func__,
					 priv->aer_uerr_mask_reg);

				pci_save_state(priv->pci_dev);

				priv->state = ST_AER_DISABLED;
				dev_info(dev, "Upstream AER disabled\n");
			}
            		break;
		case FPGA_ENABLE_UPSTREAM_AER:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_ENABLE_UPSTREAM_AER:" );
			dev_info(dev, "Preparing to enable upstream AER\n");
			if (priv->state == ST_AER_DISABLED) {
				pci_restore_state(priv->pci_dev);
				dev_info(dev, "%s setting aer to %x\n",
					 __func__, priv->aer_uerr_mask_reg);

				set_aer_uerr_mask_reg(priv->pci_upstream_dev,
						      priv->aer_uerr_mask_reg);

				/*
				 * USed for after full chip configuration, to ensure the correct speed is reported, and if not,
				 * re initialize
				 */
				retrain_device_speed(priv->pci_dev, priv->pci_upstream_dev);
				priv->state = ST_IDLE;
			} else if (priv->state == ST_IDLE) {
				dev_info(dev, "PR subsystem already idle\n");
			} else {
				dev_err(dev, "Invalid state for idling: %s",
					priv->state);
				return -EINVAL;
			}
			dev_info(dev, "Upstream AER enabled\n");
			break;

		case FPGA_INITIATE_PR:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_INITIATE_PR:" );
			dev_info(dev, "Preparing to initiate PR\n");

			if (copy_from_user(&pr_args, (pr_arg_t *)arg, sizeof(pr_arg_t)))
			{
				return -EACCES;
			}

			fp = filp_open(pr_args.rbf_name, O_RDONLY, 0);
			if (IS_ERR(fp)) {
				printk("Cannot open the file %ld\n", PTR_ERR(fp));
				return -1;
			}

			fpga_config_buf_load(priv, pr_args.config_timeout, fp);
			filp_close(fp, NULL);

			break;



		case FPGA_PR_REGION_CONTROLLER_FREEZE_ENABLE:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_CONTROLLER_FREEZE_ENABLE:" );
			dev_info(dev, "Preparing to freeze PR region\n");

			if (copy_from_user(&offset, (int *)arg, sizeof(int)))
			{
				return -EACCES;
			}

			result = fpga_pr_region_controller_freeze_enable(priv, offset);

			break;
	
		case FPGA_PR_REGION_CONTROLLER_FREEZE_DISABLE:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_CONTROLLER_FREEZE_DISABLE:" );
			dev_info(dev, "Preparing to unfreeze PR region\n");

			if (copy_from_user(&offset, (int *)arg, sizeof(int)))
			{
				return -EACCES;
			}

			result = fpga_pr_region_controller_freeze_disable(priv, offset);

			break;	

		case FPGA_PR_REGION_READ:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_READ:" );
			dev_info(dev, "Preparing to read from PR region\n");

			if (copy_from_user(&rw_args, (rw_arg_t *)arg, sizeof(rw_arg_t)))
			{
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_READ: access error#1" );
				return -EACCES;
			}

			rw_args.data = readl(priv->bar_addrs[ALTR_PCI_CVP_PR_BAR] + rw_args.offset);
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_READ: data = 0x%8.8x", rw_args.data );

			if (copy_to_user((rw_arg_t *)arg, &rw_args, sizeof(rw_arg_t)))
			{
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_READ: access error#2" );
				return -EACCES;
			}
dev_info(dev, "Read 0x%8.8x\n", *(( unsigned long * )( &rw_args )));

			break;	

		case FPGA_PR_REGION_WRITE:
pr_info( "my_ioctl(): JSC-Debug: case FPGA_PR_REGION_WRITE:" );
			dev_info(dev, "Preparing to write to PR region\n");

			if (copy_from_user(&rw_args, (rw_arg_t *)arg, sizeof(rw_arg_t)))
			{
				return -EACCES;
			}

			writel(rw_args.data, priv->bar_addrs[ALTR_PCI_CVP_PR_BAR] + rw_args.offset);
			data = readl(priv->bar_addrs[ALTR_PCI_CVP_PR_BAR] + rw_args.offset);
			break;			

		default:
pr_info( "my_ioctl(): JSC-Debug: default:" );
			return -EINVAL;
}
 
	return result;
}

//File open operation for the character device
static int my_open(struct inode *i, struct file *f)
{
	struct fpga_pcie_priv *priv = 0;

	/* pointer to containing data structure of the character device inode */
	priv = container_of(i->i_cdev, struct fpga_pcie_priv, cdev);
	f->private_data = priv;
pr_info( "my_open(): JSC-Debug" );
	return 0;
}

//File close operation for the character device
static int my_close(struct inode *i, struct file *f)
{
    return 0;
}

//File operations for char device
static struct file_operations query_fops =
{
    .owner = THIS_MODULE,
    .open = my_open,
    .release = my_close,
#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,35))
    .ioctl = my_ioctl
#else
    .unlocked_ioctl = my_ioctl
#endif
};

// Funtion is used as a callback for creation of char device. Sets char device as writable
// for any user.
static char *tty_devnode(struct device *dev, umode_t *mode)
{
	if (!mode)
		return NULL;
	*mode = 0666;
	return NULL;
}

// Function used to initialize the char device for this driver
static int __init init_chrdev (struct fpga_pcie_priv *priv) {

	int ret = 0;
	struct device *dev_ret;


pr_info( "init_chrdev(): JSC-Debug" );
	if ((ret = alloc_chrdev_region(&devt, FIRST_MINOR, MINOR_CNT, "fpga_pcie")) < 0)
	{
		return ret;
	}
pr_info( "init_chrdev(): ret=%d, JSC-Debug", ret );

	cdev_init(&priv->cdev, &query_fops);

	if ((ret = cdev_add(&priv->cdev, devt, MINOR_CNT)) < 0)
	{
		return ret;
	}

	if (IS_ERR(cl = class_create(THIS_MODULE, "char")))
	{
		cdev_del(&priv->cdev);
		unregister_chrdev_region(devt, MINOR_CNT);
		return PTR_ERR(cl);
	}
	cl->devnode = tty_devnode;
	if (IS_ERR(dev_ret = device_create(cl, NULL, devt, NULL, "fpga_pcie")))
	{
		class_destroy(cl);
		cdev_del(&priv->cdev);
		unregister_chrdev_region(devt, MINOR_CNT);
		return PTR_ERR(dev_ret);
	}

	return 0;
}

/*
 * Called for each PCIe Card that matches the ID fields we define
 * for our card, so multi card setups will have a driver deployed 
 * for each card.
 */
static int fpga_pcie_probe(struct pci_dev *dev,
				       const struct pci_device_id *id)
{
	struct fpga_pcie_priv *priv;
	int err = -EINVAL;
	u16 status = 0;

printk("JSC-Debug\n");
	/* Print some info on the PCIe device */
	dev_info(&dev->dev, "dev_name is %s\n", dev_name(&dev->dev));
	dev_info(&dev->dev, "probe (dev = 0x%p, pci id = 0x%p)\n", dev, id);
	dev_info(&dev->dev, "vendor = 0x%x, device = 0x%x, class = 0x%x\n",
		 dev->vendor, dev->device, dev->class);

	if (pcie_capability_read_word(dev, PCI_EXP_DEVCTL, &status)) {
		dev_err(&dev->dev, "pcie_capability_read_dword failed\n");
		return err;
	}

	dev_info(&dev->dev, "PCI_EXP_DEVCTL is 0x%x\n", status);

	priv = devm_kzalloc(&dev->dev, sizeof(*priv), GFP_KERNEL);
	if (!priv)
		return -ENOMEM;

	priv->state = ST_IDLE;

	INIT_LIST_HEAD(&priv->fdev_list);

	spin_lock_init(&priv->fdev_list_lock);

	err = fpga_pcie_setup_pci(dev, priv);

	if (err) {
		dev_err(&dev->dev, "failed to setup pr pci: %d\n", err);
		return err;
	}

	err = init_chrdev(priv);
		if (err) {
		dev_err(&dev->dev, "failed to setup character device: %d\n", err);
		return err;
	}

	return 0;
}

static void fpga_pcie_remove(struct pci_dev *dev)
{
	struct fpga_pcie_priv *priv = pci_get_drvdata(dev);

	device_destroy(cl, devt);
	class_destroy(cl);

	cdev_del(&priv->cdev);

	unregister_chrdev_region(devt, MINOR_CNT);

	dev_info(&dev->dev, "%s\n", __func__);


	fpga_pcie_shutdown_pci(dev, priv);

	if (priv->debugfs_root)
		debugfs_remove_recursive(priv->debugfs_root);
}

static int fpga_pcie_register_driver(void)
{
	return pci_register_driver(&fpga_pcie_driver);
}

static void fpga_pcie_unregister_driver(void)
{
	pci_unregister_driver(&fpga_pcie_driver);
}

/*
 * Initialize the driver module (but not any device) and register
 * the module with the kernel PCI subsystem. This is called only 
 * once, when  the .ko is loaded into the kernel. Once registered,
 * the Kernel calls the probe routine for the drivers registered 
 * object
 */
static int __init fpga_pcie_init(void)
{

	int err;

pr_info( "fpga_pcie_init(): JSC-Debug" );
	pr_notice("%s %s\n", DRIVER_DESCRIPTION,
		  DRIVER_VERSION);

	err = fpga_pcie_register_driver();
	if (err < 0) {
		pr_err("fpga_pcie: PCI Registration FAIL\n");
		goto err_out;
	}


	pr_info("fpga_pcie: PCI Registration PASS %d\n", err);

	return 0;

err_out:
	fpga_pcie_unregister_driver();

	return err;
}
/*
 * Called when removing the driver goes through driver and "Cleans up
 * after ourselves"
 */
static void __exit fpga_pcie_exit(void)
{
	pr_info("fpga_pcie: Removing driver");

	/* unregister this driver from the PCI bus driver */
	fpga_pcie_unregister_driver();
}

/*
* Declares the entry and exit points of the driver to the kernel
*/
module_init(fpga_pcie_init);
module_exit(fpga_pcie_exit);

/*
 * The main object that contains the information for our PCIe 
 * card, and how the kernel interacts with the card.
 */
static struct pci_driver fpga_pcie_driver = {
	.name = DRIVER_NAME,
	.id_table = fpga_pcie_pci_ids,
	.probe = fpga_pcie_probe,
	.remove = fpga_pcie_remove,
	/* resume and suspend are optional */
};

MODULE_AUTHOR("Kalen Brunham <kbrunham@intel.com>");
MODULE_DESCRIPTION(DRIVER_DESCRIPTION);
MODULE_SUPPORTED_DEVICE("PCIe Boards with FPGAs");
MODULE_LICENSE("GPL v2");
