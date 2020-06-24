package org.volante.abm.template.visualisation;

import java.awt.Color;

import org.volante.abm.visualisation.AgentTypeDisplay;

public class TestAgents extends AgentTypeDisplay
{	
	/**
	 * 
	 */
	private static final long serialVersionUID = -8136199562481069547L;

	public TestAgents()
	{
		addAgent("AT1", Color.yellow.darker());
		addAgent("AT2", Color.green.brighter());
		addAgent("AT3", Color.blue.darker());
	}
}
