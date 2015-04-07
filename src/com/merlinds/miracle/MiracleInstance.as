/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:13
 */
package com.merlinds.miracle {

	import com.adobe.utils.AGALMiniAssembler;
	import com.merlinds.miracle.utils.ContextDisposeState;

	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Program3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	[Event(type="flash.events.Event", name="complete")]
	[Event(type="flash.events.Event", name="complete")]

	internal class MiracleInstance extends EventDispatcher{
		//only for dev stage
		private var _agal:AGALMiniAssembler;
		private var _stage3D:Stage3D;
		private var _nativeStage:Stage;
		private var _context:Context3D;
		private var _scene:IRenderer;
		//
		private var _executeQueue:Vector.<Function>;
		//
		private var _enableErrorChecking:Boolean;
		private var _viewport:Rectangle;
		private var _ratioX:Number;
		private var _ratioY:Number;
		private var _onPause:Boolean;
		private var _reloading:Boolean;
		//
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleInstance(nativeStage:Stage, viewport:Rectangle = null) {
			_nativeStage = nativeStage;
			_viewport = viewport == null ? new Rectangle(0, 0, nativeStage.stageWidth,
					nativeStage.stageHeight) : viewport;
			_onPause = true;
		}

		public function start(enableErrorChecking:Boolean = true):void {
			_agal = new AGALMiniAssembler();
			_executeQueue = new <Function>[this.setupContext, this.updateShader, this.completeMethod];
			_enableErrorChecking = enableErrorChecking;
			_stage3D = _nativeStage.stage3Ds[0];
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, this.contextCreateHandler);
			_stage3D.requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE_CONSTRAINED);
		}

		public function pause():void {
			if(!_onPause){
				_onPause = true;
				if(_scene != null){
					_scene.pause();
//					_context.dispose();//fro disposing test
				}
			}
		}

		public function resume():void {
			if(_onPause){
				//start looping
				if(!_reloading){
					_onPause = false;
					_scene.resume();
				}
			}
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function setupContext():void{
			if(_enableErrorChecking)
				trace("Miracle: Setup context");
			_context.enableErrorChecking = _enableErrorChecking;
			_context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			this.updateViewport();
			//set vertex buffers
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([_ratioX, -_ratioX, 0, _ratioX]));
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, Vector.<Number>([-_ratioY, _ratioY, 0, -_ratioY]));
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 125, Vector.<Number>([1, -1, 0, 0]));
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 126, Vector.<Number>([0, 0, 1, 0]));
			_context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 127, Vector.<Number>([0, 0, 0, 1]));
			setTimeout(_executeQueue.shift(), 0, ShaderLib.VERTEX_SHADER, ShaderLib.FRAGMENT_SHADER);
		}

		private function updateViewport():void {
			if(_enableErrorChecking)
				trace("Miracle: Update viewport");
			//TODO update viewport by old one
			_viewport.width = _nativeStage.stageWidth;
			_viewport.height = _nativeStage.stageHeight;
			_context.configureBackBuffer(_viewport.width, _viewport.height, 0, false);
			_ratioX = 2 / _viewport.width;
			_ratioY = 2 / _viewport.height;
		}

		private function updateShader(vs:String, fs:String):void {
			if(_enableErrorChecking)
				trace("Miracle: Update shader");
			var program:Program3D = _context.createProgram();
			program.upload(
					_agal.assemble(Context3DProgramType.VERTEX, vs),
					_agal.assemble(Context3DProgramType.FRAGMENT, fs)
			);
			_context.setProgram(program);
			setTimeout( _executeQueue.shift(), 0 );
		}

		private function completeMethod():void {
			_onPause = true;
			if(_reloading){
				//restore scene
				//reinitialize scene with new 3DContext
				this.scene = _scene;
				/*
				 * On mobile devices 3DContext can be disposed while textures restoring.
				 * To handle this issue start check 3DContext by timer
				 */
				_nativeStage.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
				_scene.restore(this.completeMethod);
				_reloading = false;
			}else{
				_nativeStage.removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
				this.dispatchEvent( new Event(Event.COMPLETE) );
			}
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		private function contextCreateHandler(event:Event):void{
			_stage3D.removeEventListener(event.type, arguments.callee);
			_context = _stage3D.context3D;
			if(_enableErrorChecking)
				trace("Miracle: context3D was obtained", "3D driver:", _context.driverInfo);
			setTimeout(_executeQueue.shift(), 0);
		}

		private function lostContextCallback():void {
			if(!reloading){
				//Do not dispatch complete event if reloading already started
				this.dispatchEvent(new Event(Event.CLOSE));
				this.pause();
			}
			this.start(_enableErrorChecking);
			_reloading = true;
		}

		private function enterFrameHandler(event:Event):void {
			if(_context == null || _context.driverInfo == ContextDisposeState.DISPOSED){
				if(_enableErrorChecking)
					trace("Miracle: Context was lost twice");
				_nativeStage.removeEventListener(event.type, this.enterFrameHandler);
				_scene.stopRestoring();
				this.lostContextCallback();
			}
		}
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function set scene(value:IRenderer):void{
			value.initialize(_context, _nativeStage, lostContextCallback);
			value.debugOn = _enableErrorChecking;
			_scene = value;
		}

		public function get scene():IRenderer{
			return _scene;
		}

		public function get reloading():Boolean {
			return _reloading;
		}
//} endregion GETTERS/SETTERS ==================================================
	}
}