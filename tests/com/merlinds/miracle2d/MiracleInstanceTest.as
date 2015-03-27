/**
 * Created by MerlinDS on 27.03.2015.
 */
package com.merlinds.miracle2d
{

	import flash.display.Stage;

	public class MiracleInstanceTest
	{

		//======================================================================================================================
//{region											PUBLIC METHODS
		public function MiracleInstanceTest()
		{
		}

		[Before]
		public function setUp():void
		{
			Miracle2D.install(null, null);
			Miracle2D.install(null, null);
		}

		[After]
		public function tearDown():void
		{

		}

		[Test]
		public function testInstall():void
		{
			var stage:Stage;
		}

//} endregion PUBLIC METHODS ===========================================================================================
//======================================================================================================================
//{region										PRIVATE\PROTECTED METHODS
//} endregion PRIVATE\PROTECTED METHODS ================================================================================
//======================================================================================================================
//{region											GETTERS/SETTERS

//} endregion GETTERS/SETTERS ==========================================================================================

	}
}
