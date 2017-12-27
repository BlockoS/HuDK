#include <HuDK.h>


void Vhandler(void)
{
	
}

void Hhandler(void)
{
	
}

void main(void)
{
	VDC_setVSyncHandler( &Vhandler );
	VDC_setHSyncHandler( &Hhandler );
	

	while (1)
	{

	}
}
