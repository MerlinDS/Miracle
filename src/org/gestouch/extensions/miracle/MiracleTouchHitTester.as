/**
 * User: MerlinDS
 * Date: 19.09.2014
 * Time: 18:16
 */
package org.gestouch.extensions.miracle {
	import com.merlinds.miracle.Miracle;
	import com.merlinds.miracle.display.MiracleDisplayObject;

	import flash.geom.Point;

	import org.gestouch.core.ITouchHitTester;

	public class MiracleTouchHitTester implements ITouchHitTester{

		private var _displayObject:Object;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleTouchHitTester(displayObject:MiracleDisplayObject = null) {
			if(displayObject != null){
				trace("MiracleTouchHitTester add", displayObject.mesh, displayObject.animation);
			}
			_displayObject = displayObject;
		}

		public function hitTest(point:Point, possibleTarget:Object = null):Object {
			if (possibleTarget && possibleTarget is MiracleDisplayObject)
			{
				return possibleTarget;
			}
			//calculate hit test
			return Miracle.currentScene.hitTest(point);
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
