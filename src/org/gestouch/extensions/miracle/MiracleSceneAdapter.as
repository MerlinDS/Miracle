/**
 * User: MerlinDS
 * Date: 19.09.2014
 * Time: 19:25
 */
package org.gestouch.extensions.miracle {
	import com.merlinds.miracle.IScene;
	import com.merlinds.miracle.display.MiracleDisplayObject;

	import flash.utils.Dictionary;

	import org.gestouch.core.IDisplayListAdapter;

	public class MiracleSceneAdapter implements IDisplayListAdapter {

		protected var _targetWeekStorage:Dictionary;
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleSceneAdapter(displayObject:Object = null) {
			if(displayObject != null){
				_targetWeekStorage = new Dictionary(true);
				_targetWeekStorage[displayObject] = true;
			}
		}

		public function contains(object:Object):Boolean {
			return object is IScene;
		}

		public function getHierarchy(target:Object):Vector.<Object> {
			return new <Object>[target];
		}

		public function reflect():Class {
			return MiracleSceneAdapter;
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
		public function get target():Object {
			for (var key:Object in _targetWeekStorage)
			{
				return key;
			}
			return null;
		}
		//} endregion GETTERS/SETTERS ==================================================
	}
}
