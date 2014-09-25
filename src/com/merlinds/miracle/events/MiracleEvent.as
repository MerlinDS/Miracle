/**
 * User: MerlinDS
 * Date: 10.07.2014
 * Time: 16:31
 */
package com.merlinds.miracle.events {
	import flash.events.Event;

	public class MiracleEvent extends Event {

		public static const ADDED_TO_STAGE:String = "addedToStage";
		public static const REMOVED_FROM_STAGE:String = "removedFromStage";
		public static const PLAYBACK_COMPLETE:String = "playbackComplete";
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleEvent(type:String) {
			super(type, false, false);
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
