#version 150 core

in vec3 position;
in vec3 color;
in float diameter;
//in float index;
out vec3 Color;
//out vec2 Pos;
//out float Diameter;
uniform mat4 Model;
uniform mat4 View;
uniform mat4 Projection;
uniform float minLon;
uniform float minLat;
uniform float maxLon;
uniform float maxLat;
uniform float windowWidth;
uniform float windowHeight;
uniform float centerLat;
uniform float centerLon;

uniform float magnification;
uniform float dpi = 96.0;
uniform float z;

uniform float PI = 3.1415926535897;

vec2 PixelToGeo(in float x, in float y, in float latOffset)
{
    float tileDPI=96.0;
    float gradtorad=2*PI/360;
    float earthRadiusMeter=6378137.0;
    float earthExtentMeter=2*PI*earthRadiusMeter;
    float tileWidthZoom0Aquator=earthExtentMeter;
    float equatorTileWidth=tileWidthZoom0Aquator/magnification;
    float equatorTileResolution=equatorTileWidth/256.0;
    float equatorCorrectedEquatorTileResolution=equatorTileResolution*tileDPI/dpi;
    float groundWidthEquatorMeter=windowWidth*equatorCorrectedEquatorTileResolution;

    float scale=windowWidth/(2*PI*groundWidthEquatorMeter/earthExtentMeter);
    float scaleGradtorad=scale*gradtorad;

    x-=windowWidth/2;
    y=windowHeight/2-y;

    float lon=centerLon+x/scaleGradtorad;
    float lat=atan(sinh(y/scale+latOffset))/gradtorad;

    vec2 result = vec2(lon,lat);
    return (result);
}

vec2 GeoToPixel(in float posx, in float posy){
    float tileDPI=96.0;
    float gradtorad=2*PI/360;
    float earthRadiusMeter=6378137.0;
    float earthExtentMeter=2*PI*earthRadiusMeter;
    float tileWidthZoom0Aquator=earthExtentMeter;
    float equatorTileWidth=tileWidthZoom0Aquator/magnification;
    float equatorTileResolution=equatorTileWidth/256.0;
    float equatorCorrectedEquatorTileResolution=equatorTileResolution*tileDPI/dpi;
    float groundWidthEquatorMeter=windowWidth*equatorCorrectedEquatorTileResolution;
    float groundWidthVisibleMeter=groundWidthEquatorMeter*cos(posy*gradtorad);

    float latOffset=atanh(sin(centerLat*gradtorad));

    vec2 tl = PixelToGeo(0.0,0.0,latOffset);
    vec2 tr = PixelToGeo(windowWidth,0.0,latOffset);
    vec2 bl = PixelToGeo(0.0,windowHeight,latOffset);
    vec2 br = PixelToGeo(windowWidth,windowHeight,latOffset);

    float MaxLat = +85.0511;
    float MinLat = -85.0511;
    float MaxLon = +180.0;
    float MinLon = -180.0;

    float latMin=max(MinLat,min(min(tl.y,tr.y),min(bl.y,br.y)));
    float latMax=min(MaxLat,max(max(tl.y,tr.y),max(bl.y,br.y)));

    float lonMin=max(MinLon,min(min(tl.x,tr.x),min(bl.x,br.x)));
    float lonMax=min(MaxLon,max(max(tl.x,tr.x),max(bl.x,br.x)));

    float scale=windowWidth/(2*PI*groundWidthEquatorMeter/earthExtentMeter);
    float scaleGradtorad=scale*gradtorad;

    float latDeriv = 1.0 / sin( (2 * centerLat * gradtorad + PI) /  2);
    float scaledLatDeriv = latDeriv * gradtorad * scale;

    float windowPosX=(posx-centerLon)*scaledLatDeriv;
    float windowPosY=(atanh(sin(posy*gradtorad))-latOffset)*scale;

    windowPosY=windowHeight/2-windowPosY;
    windowPosX += windowWidth/2;

    float MinX = (lonMin-centerLon)*scaledLatDeriv + windowWidth/2;
    float MinY = windowHeight/2 - (atanh(sin(latMin*gradtorad))-latOffset)*scale;
    float MaxX = (lonMax-centerLon)*scaledLatDeriv + windowWidth/2;
    float MaxY = windowHeight/2 - (atanh(sin(latMax*gradtorad))-latOffset)*scale;

    float newWidth = windowWidth/windowHeight;
    float newHeight = 1;

    float screenX = ((2*newWidth)*(windowPosX - (MinX))/((MaxX)-(MinX)))-newWidth;
    float screenY = ((2*newHeight)*(windowPosY - (MinY))/((MaxY)-(MinY)))-newHeight;

    vec2 result = vec2(screenX, screenY);
    return(result);
}

vec2 GeoToWindow(in float posx, in float posy){
    float tileDPI=96.0;
    float gradtorad=2*PI/360;
    float earthRadiusMeter=6378137.0;
    float earthExtentMeter=2*PI*earthRadiusMeter;
    float tileWidthZoom0Aquator=earthExtentMeter;
    float equatorTileWidth=tileWidthZoom0Aquator/magnification;
    float equatorTileResolution=equatorTileWidth/256.0;
    float equatorCorrectedEquatorTileResolution=equatorTileResolution*tileDPI/dpi;
    float groundWidthEquatorMeter=windowWidth*equatorCorrectedEquatorTileResolution;
    float groundWidthVisibleMeter=groundWidthEquatorMeter*cos(posy*gradtorad);

    float latOffset=atanh(sin(centerLat*gradtorad));

    vec2 tl = PixelToGeo(0.0,0.0,latOffset);
    vec2 tr = PixelToGeo(windowWidth,0.0,latOffset);
    vec2 bl = PixelToGeo(0.0,windowHeight,latOffset);
    vec2 br = PixelToGeo(windowWidth,windowHeight,latOffset);

    float MaxLat = +85.0511;
    float MinLat = -85.0511;
    float MaxLon = +180.0;
    float MinLon = -180.0;

    float latMin=max(MinLat,min(min(tl.y,tr.y),min(bl.y,br.y)));
    float latMax=min(MaxLat,max(max(tl.y,tr.y),max(bl.y,br.y)));

    float lonMin=max(MinLon,min(min(tl.x,tr.x),min(bl.x,br.x)));
    float lonMax=min(MaxLon,max(max(tl.x,tr.x),max(bl.x,br.x)));

    float scale=windowWidth/(2*PI*groundWidthEquatorMeter/earthExtentMeter);
    float scaleGradtorad=scale*gradtorad;

    float latDeriv = 1.0 / sin( (2 * centerLat * gradtorad + PI) /  2);
    float scaledLatDeriv = latDeriv * gradtorad * scale;

    float windowPosX=(posx-centerLon)*scaledLatDeriv;
    float windowPosY=(atanh(sin(posy*gradtorad))-latOffset)*scale;

    windowPosY=windowHeight/2-windowPosY;
    windowPosX += windowWidth/2;

    vec2 result = vec2(windowPosX, windowPosY);
    return(result);
}

void main() {
    float diam = diameter/2;
    //float width_norm = (ceil(diam)/windowWidth);
    //float height_norm = (ceil(diam)/windowHeight);
    vec2 c = GeoToPixel(position.x, position.y);
    //WindowPos = GeoToWindow(position.x, position.y);
    //WindowPos2 = vec2(1.0, 1.0);
    //WindowPos = GeoToPixel(position.x, position.y);
    vec4 pos = Projection * View * Model * vec4(c.x, c.y, position.z, 1);

    Color = color;
    //Diameter = diam;

    if(position.z > 0)
        gl_PointSize = diameter - (diameter/10);
    else
        gl_PointSize = diameter;

    gl_Position = pos;
    /*gl_Position = pos;
	if(index == 1.0){
        gl_Position = vec4(pos.x - width_norm/2, pos.y - height_norm/2, pos.z, pos.w);
        Pos = vec2(pos.x - width_norm/2, pos.y - height_norm/2);
    }
	else if(index == 2.0){
	    gl_Position = vec4(pos.x + width_norm/2, pos.y - height_norm/2, pos.z, pos.w);
	    Pos = vec2(pos.x + width_norm/2, pos.y - height_norm/2);
	}
	else if(index == 3.0){
	    gl_Position = vec4(pos.x + width_norm/2, pos.y + height_norm/2, pos.z, pos.w);
	    Pos = vec2(pos.x + width_norm/2, pos.y + height_norm/2);
	}
	else{
	    gl_Position = vec4(pos.x - width_norm/2, pos.y + height_norm/2, pos.z, pos.w);
	    Pos = vec2(pos.x - width_norm/2, pos.y + height_norm/2);
	}*/
}