/**
 * User: MerlinDS
 * Date: 31.03.2014
 * Time: 21:49
 */
package com.merlinds.miracle {
	internal class ShaderLib {

		public static const VERTEX_SHADER:String = [
			/*
			 * va[0] = [x, y] Need z
			 * va[1] = [u, v]
			 * va[2] = [tx,ty]
			 * va[3] = [scaleX, scaleY, skewX, skewY]
			 * Need argb buffer for color changing

			 * vc[125] = [1,-1,0,0]
			 * vc[126] = [0,0,1,0]
			 * vc[127] = [0,0,0,1]

			 * m1 formula:[scaleX*Math.cos(skewY), scaleY*Math.sin(-skewX), 0, tx] //a, c, 0, tx
			 * m2 formula:[scaleX*Math.sin(skewY), scaleY*Math.cos(skewX), 0, ty] //b, d, 0, ty
			 * view formula m1:[a*ratioX, c*-ratioX, 0, tx*ratioX-1], m2:[b*-ratioY, d*ratioY, 0, ty*-ratioY+1]
			 */

			"mul vt3.x, va3.z, vc125.y", //skewX * -1, get -1 from vc125.y
			"cos vt0.x, va3.w", //cos(skewY)
			"sin vt0.y, vt3.x", //sin(-skewX)
			"sin vt0.z, va3.w", //sin(skewY)
			"cos vt0.w, va3.z", //cos(skewX)

			"mul vt1.x, va3.x, vt0.x",  //a
			"mul vt1.y, va3.y, vt0.y",  //c
			"mov vt1.z, vc127.z", //0
			"mov vt1.w, va2.x", //tx

			"mul vt2.x, va3.x, vt0.z",  //b
			"mul vt2.y, va3.y, vt0.w",  //d
			"mov vt2.z, vc127.z", //0
			"mov vt2.w, va2.y", //ty

			"mul vt1, vt1, vc0", //apply view ratio
			"sub vt1.w, vt1.w, vc125.x", //apply view position, tx - 1, get 1 from vc125.x

			"mul vt2, vt2, vc1", //apply view ratio
			"add vt2.w, vt2.w, vc125.x", //apply view position, ty + 1

			"dp4 op.x, va0, vt1",
			"dp4 op.y, va0, vt2",
			"dp4 op.z, va0, vc126",
			"dp4 op.w, va0, vc127",
			"mov v1, va1.xy"
		].join("\n");


		public static const FRAGMENT_SHADER:String = [
			"tex oc, v1, fs0 <2d,linear,nomip>"
		].join("\n");

		/*public static const FRAGMENT_SHADER:String = [
		 "tex ft0, v1, fs0 <2d,linear,nomip>",
		 "mul oc, ft0, v0"
		 ].join("\n")*/


		public function ShaderLib() {
		}

		//==============================================================================
		//{region							PUBLIC METHODS
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
