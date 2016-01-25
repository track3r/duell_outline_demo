/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package tests.outlineTest;

import types.Matrix4;
import types.Matrix4Tools;
import types.DataType;
import tests.meshTest.AnimatedMesh;
import haxe.ds.StringMap;
import types.Color4F;
import haxe.CallStack;
import types.VerticalAlignment;
import types.HorizontalAlignment;
import types.Range;
import tests.utils.Bitmap;
import tests.utils.ImageDecoder;
import tests.utils.AssetLoader;
import duellkit.DuellKit;
import tests.utils.Shader;
import types.Data;
import gl.GL;
import gl.GLDefines;

using types.Matrix4Tools;

class OutlineTest extends OpenGLTest
{
    inline private static var IMAGE_PATH = "libraryTest/images/lena.png";
    inline private static var FONT_PATH_ARIAL = "libraryTest/fonts/arial.ttf";
    inline private static var FONT_PATH_COMIC = "libraryTest/fonts/Pacifico.ttf";
    inline private static var FONT_PATH_JAPAN = "libraryTest/fonts/font_1_ant-kaku.ttf";

    inline private static var VERTEXSHADER_PATH = "common/shaders/Base_PosColorTex.vsh";
    inline private static var FRAGMENTSHADER_PATH = "common/shaders/Outline.fsh";

    //inline private static var VERTEXSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.vsh";
    //inline private static var FRAGMENTSHADER_PATH = "common/shaders/ScreenSpace_PosColorTex.fsh";


    private var textureShader: Shader;
    private var animatedMesh: AnimatedMesh;
    private var projection: Matrix4;

    static private var texture: GLTexture;

    static var enterFrame: Void -> Void = null;

// Create OpenGL objectes (Shaders, Buffers, Textures) here
    override private function onCreate(): Void
    {
        super.onCreate();

        configureOpenGLState();
        createShader();
        createMesh();

        createTexture();
    }

// Destroy your created OpenGL objectes
    override public function onDestroy(): Void
    {
        destroyTexture();
        destroyMesh();
        destroyShader();

        super.onDestroy();
    }

    private function configureOpenGLState(): Void
    {
        GL.clearColor(0.5, 0.5, 0.5, 1.0);
        projection = new Matrix4();
        var dk: DuellKit = DuellKit.instance();
        //GL.viewport(0, 0, Math.ceil(dk.screenWidth), Math.ceil(dk.screenHeight));
        projection.setIdentity();
        //projection.setOrtho(0, dk.screenWidth, dk.screenHeight, 0, 0, 1);
        //projection.set2D(-1, -1, 1, 0);
        projection.translate(-1, -1, 0);
        //projection.
    }

    private function createShader()
    {
        var vertexShader: String = AssetLoader.getStringFromFile(VERTEXSHADER_PATH);
        var fragmentShader: String = AssetLoader.getStringFromFile(FRAGMENTSHADER_PATH);
        trace(vertexShader);
        trace(fragmentShader);

        textureShader = new Shader();
        textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color", "a_TexCoord"], ["u_MVPMatrix", "s_Texture", "u_OutlineStep", "u_OutlineColor"]);
        //textureShader.createShader(vertexShader, fragmentShader, ["a_Position", "a_Color", "a_TexCoord"],  ["u_Tint", "u_MVPMatrix", "s_Texture"]);
    }

    private function destroyShader(): Void
    {
        textureShader.destroyShader();
    }

    private function createMesh()
    {
        var h = 1024./768.;
        animatedMesh = new AnimatedMesh();
        animatedMesh.width = 1;
        animatedMesh.height = h;
        animatedMesh.createBuffers();
    }

    private function destroyMesh()
    {
        animatedMesh.destroyBuffers();
    }


    private function destroyTexture(): Void
    {
        GL.deleteTexture(texture);
    }

    private function update(deltaTime: Float, currentTime: Float)
    {
        if (enterFrame != null)
        {
            enterFrame();
        }
    }

    private function createTexture(): Void
    {
/// Create RGBA raw pixel data

        var pngData = AssetLoader.getDataFromFile("common/Giant1.png");
        var png = ImageDecoder.decodePNG(pngData);

/// Create, configure and upload opengl texture

        texture = GL.createTexture();

        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

// Configure Filtering Mode
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MAG_FILTER, GLDefines.LINEAR);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_MIN_FILTER, GLDefines.LINEAR);

// Configure wrapping
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_S, GLDefines.REPEAT);
        GL.texParameteri(GLDefines.TEXTURE_2D, GLDefines.TEXTURE_WRAP_T, GLDefines.REPEAT);

// Copy data to gpu memory
        GL.pixelStorei(GLDefines.UNPACK_ALIGNMENT, 4);
        GL.texImage2D(GLDefines.TEXTURE_2D, 0, GLDefines.RGBA, png.width, png.height, 0, GLDefines.RGBA, GLDefines.UNSIGNED_BYTE, png.data);

        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);
    }


    override private function render()
    {
        GL.clear(GLDefines.COLOR_BUFFER_BIT);

        update(DuellKit.instance().frameDelta, DuellKit.instance().time);

        GL.useProgram(textureShader.shaderProgram);

        //GL.uniform4f(textureShader.uniformLocations[0], 1.0, 1.0, 1.0, 1.0);
        GL.uniformMatrix4fv(textureShader.uniformLocations[0], 1, false, projection.data);

        //step value must be close to pixel size
        GL.uniform2f(textureShader.uniformLocations[2], 2. / 512, 2. / 512);

        //outline color
        GL.uniform4f(textureShader.uniformLocations[3], 0.0, 0.0, 0.0, 1.0);

        GL.activeTexture(GLDefines.TEXTURE0);
        GL.bindTexture(GLDefines.TEXTURE_2D, texture);

        animatedMesh.bindMesh();

        animatedMesh.draw();

        animatedMesh.unbindMesh();
        GL.bindTexture(GLDefines.TEXTURE_2D, GL.nullTexture);
        GL.useProgram(GL.nullProgram);
    }
}