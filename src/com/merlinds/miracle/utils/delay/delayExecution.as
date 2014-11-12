/**
 * User: MerlinDS
 * Date: 12.11.2014
 * Time: 14:02
 */
package com.merlinds.miracle.utils.delay {

	public function delayExecution(method:Function, delay:int = 0, ...args):DelayMethod{
		var delayMethod:DelayMethod = new DelayMethod(method, delay, args);
		DelayManager.getInstance().add(delayMethod);
		return delayMethod;
	}
}
