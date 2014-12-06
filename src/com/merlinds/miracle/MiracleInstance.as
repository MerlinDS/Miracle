/**
 * User: MerlinDS
 * Date: 01.04.2014
 * Time: 19:13
 */
package com.merlinds.miracle {

	import com.adobe.utils.AGALMiniAssembler;

	import flash.display.BitmapData;
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
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	internal class MiracleInstance extends EventDispatcher{
		private var _agal:AGALMiniAssembler;
		private var _stage3D:Stage3D;
		private var _nativeStage:Stage;
		private var _context:Context3D;
		private var _scene:IRenderer;
		//
		private var _executeQueue:Vector.<Function>;
		//
		private var _lastFrameTimestamp:Number;
		private var _enableErrorChecking:Boolean;
		private var _viewport:Rectangle;
		private var _ratioX:Number;
		private var _ratioY:Number;
		private var _onPause:Boolean;
		//
		//==============================================================================
		//{region							PUBLIC METHODS
		public function MiracleInstance(nativeStage:Stage, viewport:Rectangle = null) {
			_nativeStage = nativeStage;
			_viewport = viewport == null ? new Rectangle(0, 0, nativeStage.stageWidth,
					nativeStage.stageHeight) : viewport;
		}

		public function start(enableErrorChecking:Boolean = true):void {
			_agal = new AGALMiniAssembler();
			_executeQueue = new <Function>[this.setupContext, this.updateShader, this.completeMethod];
			_enableErrorChecking = enableErrorChecking;
			_stage3D = _nativeStage.stage3Ds[0];
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, this.contextCreateHandler);
			_stage3D.requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
		}

		public function pause():void {
			_onPause = true;
			if(_scene != null && _context != null){
				//clear GPU from graphics till miracle on pause
				/*_scene.start();
				_scene.end();*/
				//test context loosing
//				_context.dispose();
			}
			_nativeStage.removeEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
		}

		public function resume():void {
			_onPause = false;
			//start looping
			_lastFrameTimestamp = getTimer();
			_nativeStage.addEventListener(Event.ENTER_FRAME, this.enterFrameHandler);
		}
		//} endregion PUBLIC METHODS ===================================================

		//==============================================================================
		//{region						PRIVATE\PROTECTED METHODS
		private function setupContext():void{
			trace("Miracle: Setup context");
			_context.enableErrorChecking = _enableErrorChecking;
			_context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			this.updateViewport();
			//set vertex buffers
			_context.setProgramConstantsFromVector("vertex", 0, Vector.<Number>([_ratioX, -_ratioX, 0, _ratioX]));
			_context.setProgramConstantsFromVector("vertex", 1, Vector.<Number>([-_ratioY, _ratioY, 0, -_ratioY]));
			_context.setProgramConstantsFromVector("vertex", 125, Vector.<Number>([1, -1, 0, 0]));
			_context.setProgramConstantsFromVector("vertex", 126, Vector.<Number>([0, 0, 1, 0]));
			_context.setProgramConstantsFromVector("vertex", 127, Vector.<Number>([0, 0, 0, 1]));
			setTimeout(_executeQueue.shift(), 0, ShaderLib.VERTEX_SHADER, ShaderLib.FRAGMENT_SHADER);
		}

		private function updateViewport():void {
			trace("Miracle: Update viewport");
			//TODO update viewport by old one
			_viewport.width = _nativeStage.stageWidth;
			_viewport.height = _nativeStage.stageHeight;
			_context.configureBackBuffer(_viewport.width, _viewport.height, 0, false);
			_ratioX = 2 / _viewport.width;
			_ratioY = 2 / _viewport.height;
		}

		private function updateShader(vs:String, fs:String):void {
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
			this.dispatchEvent( new Event(Event.COMPLETE) );
		}
		//} endregion PRIVATE\PROTECTED METHODS ========================================

		//==============================================================================
		//{region							EVENTS HANDLERS
		private function contextCreateHandler(event:Event):void{
			_stage3D.removeEventListener(event.type, arguments.callee);
			_context = _stage3D.context3D;
			trace("Miracle: context3D was obtained", "3D driver:", _context.driverInfo);
			setTimeout(_executeQueue.shift(), 0);
		}

		private function enterFrameHandler(event:Event):void {
			var now:Number = getTimer();
			var passedTime:Number = now - _lastFrameTimestamp;
			_lastFrameTimestamp = now;
			this.executeFrame(passedTime);
		}

		private function executeFrame(time:Number):void{
			//draw frame
			if(_scene != null && _context != null && !_onPause){
				_scene.start();
				_scene.drawFrame(time);
				_scene.end();
			}
		}
		//} endregion EVENTS HANDLERS ==================================================

		//==============================================================================
		//{region							GETTERS/SETTERS
		public function set scene(value:IRenderer):void{
			//clear old scene if it exist
			if(_scene != null){
				_scene.context = null;
			}
			//add new scene and context to it
			_scene = value;
			_scene.context = _context;
		}

		public function get scene():IRenderer{
			return _scene;
		}

//} endregion GETTERS/SETTERS ==================================================
	}
}