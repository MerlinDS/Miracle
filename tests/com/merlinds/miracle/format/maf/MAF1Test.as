/**
 * User: MerlinDS
 * Date: 19.02.2015
 * Time: 19:22
 */
package com.merlinds.miracle.format.maf {
	import com.merlinds.miracle.animations.FrameType;
	import com.merlinds.miracle.format.Signatures;
	import com.merlinds.miracle.geom.Color;
	import com.merlinds.miracle.geom.TransformMatrix;
	import com.merlinds.miracle.geom.Transformation;

	import flash.geom.Rectangle;

	import flexunit.framework.Assert;

	public class MAF1Test {

		//==============================================================================
		//{region							PUBLIC METHODS

		[Test]
		public function testConstructor():void {
			var file:MAF1 = new MAF1();
			var animName:String = "anim_0";
			var t:Transformation = new Transformation(
					new TransformMatrix(), new Color()
			);
			file.addAnimation(animName, new Rectangle());
			file.addTransformation(animName, 0, t);
			file.addFrame(animName, 0, FrameType.MOTION, "some polygon", 0, 1);
			var charSet:String = "us-ascii";
			var signature:String = file.readMultiByte(MAFHeaderFormat.MT, charSet);
			Assert.assertEquals("Signature", Signatures.MAF1, signature);
			Assert.assertEquals("MatrixSize", 32, file.readShort());
			Assert.assertEquals("ColorSize", 18, file.readShort());
			Assert.assertEquals("FrameSize", 10, file.readShort());
			Assert.assertNotNull("dateOfCreation", file.readInt());

		}

//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		//} endregion GETTERS/SETTERS ==================================================
	}
}
