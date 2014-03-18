package com.polymath.halloween 
{
	public class Node 
	{
		// Tile indicies
		public var x:uint;
		public var y:uint;
		
		// Cost calculations
		public var g:uint;	// The cost from here to the starting point
		public var h:uint;	// The estimated cost from here to the end point
		public var f:uint;	// f = g + h;
		
		// Relatives
		public var parent:Node;
		
		public function Node(x:uint, y:uint)
		{
			this.x = x;
			this.y = y;
			
			g = 0;
			h = 0;
			f = 0;
			parent = null;
		}
	}

}