/**
 * User: MerlinDS
 * Date: 19.09.2014
 * Time: 18:47
 */
package org.gestouch.extensions.miracle {
	import com.merlinds.miracle.IScene;
	import com.merlinds.miracle.Miracle;
	import com.merlinds.miracle.display.MiracleDisplayObject;

	public class MiracleDisplayObjectAdapter extends MiracleSceneAdapter{

		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleDisplayObjectAdapter(displayObject:Object = null) {
			super( displayObject );
		}

		override public function contains(object:Object):Boolean {
			const targetAsDOC:IScene = this.target as IScene;
			const objectAsDO:MiracleDisplayObject = object as MiracleDisplayObject;
			return targetAsDOC && objectAsDO && targetAsDOC.displayObjects.indexOf(objectAsDO) > -1;
		}

		override public function getHierarchy(target:Object):Vector.<Object> {
			return new <Object>[Miracle.currentScene, target];
		}

		override public function reflect():Class {
			return MiracleDisplayObjectAdapter;
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
