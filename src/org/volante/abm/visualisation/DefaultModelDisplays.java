/**
 * This file is part of
 * 
 * CRAFTY - Competition for Resources between Agent Functional TYpes
 *
 * Copyright (C) 2014 School of GeoScience, University of Edinburgh, Edinburgh, UK
 * 
 * CRAFTY is free software: You can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software 
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *  
 * CRAFTY is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * School of Geoscience, University of Edinburgh, Edinburgh, UK
 * 
 * Created by Sascha Holzhauer on 10.03.2014
 */
package org.volante.abm.visualisation;


import java.awt.Dimension;
import java.awt.Frame;
import java.awt.GraphicsConfiguration;
import java.awt.Rectangle;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JFrame;
import javax.swing.JTabbedPane;

import org.apache.log4j.Logger;
import org.simpleframework.xml.ElementList;
import org.volante.abm.data.ModelData;
import org.volante.abm.data.Regions;
import org.volante.abm.schedule.RunInfo;

import sun.java2d.SunGraphicsEnvironment;


/**
 * @author Sascha Holzhauer
 * 
 */
public class DefaultModelDisplays extends ModelDisplays {

	@ElementList(inline = true, entry = "display", required = false)
	List<Display>				displays			= new ArrayList<Display>();
	JFrame						frame				= new JFrame("Model Displays");
	Logger						log					= Logger.getLogger(getClass());
	JTabbedPane					tabbedPane			= null;

	public DefaultModelDisplays() {
		this.tabbedPane = new JTabbedPane();
		frame.add(this.tabbedPane);
		frame.setSize(new Dimension(800, 1200));
	}

	@Override
	public void initialise(ModelData data, RunInfo info, Regions extent) throws Exception {
		log.info("Initialising displays: " + extent.getExtent());
		for (Display d : displays) {
			d.initialise(data, info, extent);
			info.getSchedule().register(d);
			this.tabbedPane.addTab(d.getTitle(), d.getDisplay());
		}
		if (displays.size() > 0) {
			frame.setVisible(true);
		}
		for (Display d : displays) {
			registerDisplay(d);
		}

		GraphicsConfiguration config = frame.getGraphicsConfiguration();
		Rectangle usableBounds = SunGraphicsEnvironment.getUsableBounds(config.getDevice());
		frame.setMaximizedBounds(usableBounds);
		frame.setExtendedState(Frame.MAXIMIZED_BOTH);
	}

	@Override
	public void registerDisplay(Display d) {
		for (Display o : displays) {
			if (o != d) {
				d.addCellListener(o);
			}
		}
		d.setModelDisplays(this);
	}
}
