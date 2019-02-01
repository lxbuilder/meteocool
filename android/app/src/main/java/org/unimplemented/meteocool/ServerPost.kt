package org.unimplemented.meteocool

data class ServerPost(val lat : Double,
                      val lon : Double,
                      val altitude : Double,
                      val accuracy : Double,
                      val verticalAccuracy : Double,
                      val  pressure : Double,
                      val timestamp : Double,
                      val token : String,
                      val source : String,
                      val ahead : Int,
                      val intensity : Int)
