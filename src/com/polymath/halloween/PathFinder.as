package com.polymath.halloween 
{
	import org.flixel.FlxG;
	
	public class PathFinder 
	{
		private static function get level():Level
		{
			return (FlxG.state as PlayState).CurrentLevel;
		}
		
		public static function determinePath(startNode:Node, endNode:Node):Array
		{
			var openList:Array = new Array();
			var closedList:Array = new Array();
			
			var currentNode:Node = startNode;
			var adjacentNodes:Array;
			var testNode:Node;
			
			var g:uint;
			var h:uint;
			var f:uint;
			
			currentNode.g = 0;
			currentNode.h = PathFinder.getEstimatedCost(startNode, endNode);
			currentNode.f = currentNode.g + currentNode.h;
			
			while (!PathFinder.isSame(currentNode, endNode)) {
				adjacentNodes = getAdjacentNodes(currentNode);
				for (var i:uint = 0; i < adjacentNodes.length; i++) {
					testNode = adjacentNodes[i];
					if (PathFinder.isSame(testNode, currentNode)) continue;
					g = currentNode.g + 1;
					h = PathFinder.getEstimatedCost(testNode, endNode);
					f = g + h;
					if (PathFinder.listContainsNode(testNode, openList) || PathFinder.listContainsNode(testNode, closedList)) {
						if (f < testNode.f) {
							testNode.g = g;
							testNode.h = h;
							testNode.f = f;
							testNode.parent = currentNode;
						}
					} else {
						testNode.g = g;
						testNode.h = h;
						testNode.f = f;
						testNode.parent = currentNode;
						openList.push(testNode);
					}
				}
				closedList.push(currentNode);
				if (openList.length == 0)
					return null;
				openList.sortOn('f', Array.NUMERIC);
				currentNode = openList.shift() as Node;
			}
			
			return PathFinder.buildPath(startNode, currentNode);
		}
		
		private static function getEstimatedCost(startNode:Node, endNode:Node):uint
		{
			return (Math.abs(startNode.x - endNode.x) + Math.abs(startNode.y - endNode.y));
		}
		
		private static function isSame(node1:Node, node2:Node):Boolean
		{
			if (node1 == null || node2 == null)
				return false;
			return (node1.x == node2.x && node1.y == node2.y);
		}
		
		private static function getAdjacentNodes(node:Node):Array
		{
			var nodes:Array = new Array();
			var neighbor:Node;
			
			if (level.isValidSpace(node.x - 1, node.y)) {
				neighbor = new Node(node.x - 1, node.y);
				nodes.push(neighbor);
			}
			if (level.isValidSpace(node.x + 1, node.y)) {
				neighbor = new Node(node.x + 1, node.y);
				nodes.push(neighbor);
			}
			if (level.isValidSpace(node.x, node.y - 1)) {
				neighbor = new Node(node.x, node.y - 1);
				nodes.push(neighbor);
			}
			if (level.isValidSpace(node.x, node.y + 1)) {
				neighbor = new Node(node.x, node.y + 1);
				nodes.push(neighbor);
			}
			
			return nodes;
		}
		
		private static function listContainsNode(node:Node, list:Array):Boolean
		{
			for each (var nodeMember:Node in list) {
				if (PathFinder.isSame(nodeMember, node))
					return true;
			}
			return false;
		}
		
		private static function buildPath(startNode:Node, endNode:Node):Array
		{
			var path:Array = new Array();
			var curNode:Node = endNode;
			path.push(curNode);
			
			while (!PathFinder.isSame(startNode, curNode)) {
				curNode = curNode.parent;
				path.unshift(curNode);
			}
			return path;
		}
	}

}