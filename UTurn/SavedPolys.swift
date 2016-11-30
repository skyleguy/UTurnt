//
//  SavedPolys.swift
//  UTurn
//
//  Created by Stephen Kyle Lobsinger on 11/30/16.
//  Copyright © 2016 Stephen Kyle Lobsinger. All rights reserved.
//

import Foundation
import GoogleMaps

class SavedPolys : NSObject, NSCoding, NSCopying
{
    var alPoly: [GMSPolyline]?
    let polyKey = "polyKey"
    
    override init()
    {
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        alPoly = aDecoder.decodeObject(forKey: polyKey) as? [GMSPolyline]
    }
    
    func encode(with aCoder: NSCoder)
    {
        if let savePoly = alPoly
        {
            aCoder.encode(savePoly, forKey: polyKey)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = SavedPolys()
        if let polysToCopy = alPoly
        {
            var newPolys = Array<GMSPolyline>()
            for poly in polysToCopy
            {
                newPolys.append(poly)
            }
            copy.alPoly = newPolys
        }
        return copy
    }
}
