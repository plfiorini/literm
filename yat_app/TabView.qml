/*******************************************************************************
 * Copyright (C) 2017 Robin Burchell <robin+git@viroteck.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 *******************************************************************************/

import QtQuick 2.6

Column {
    id: root
    property alias currentIndex: tabBar.currentIndex
    property alias count: _tabModel.count
    TabBar {
        id: tabBar
        model: ListModel {
            id: _tabModel
        }

        onRemoveIndex: {
            root.removeTab(index)
        }
    }
    Item {
        id: tabContainer
        height: parent.height - tabBar.height
        width: parent.width
    }

    onCurrentIndexChanged: {
        for (var i = 0; i < tabContainer.children.length; ++i) {
            tabContainer.children[i].visible = i == currentIndex
        }
    }

    function _updateTabTitle() {
        // NOTE NOTE NOTE! We are called bound, meaning 'this' refers to the tab
        // item delegate, not the TabView!
        for (var i = 0; i < tabContainer.children.length; ++i) {
            var obj = getTab(i)
            if (obj.item == this) {
                obj.title = this.title
                _tabModel.set(i, obj)
                return
            }
        }
    }

    function addTab(titleText, comp) {
        if (comp.status != Component.Ready) {
            console.warn("Component not ready! " + component.errorString)
            return
        }
        var tabInstance = comp.createObject(tabContainer)
        tabInstance.titleChanged.connect(_updateTabTitle.bind(tabInstance))
        _tabModel.append({ title: tabInstance.title, item: tabInstance })
        return _tabModel.get(_tabModel.count - 1)
    }

    function removeTab(tabIndex) {
        var obj = _tabModel.get(tabIndex)
        if (obj.item && obj.item.parent)
            obj.item.destroy()
        _tabModel.remove(tabIndex)
        if (tabIndex >= currentIndex)
            currentIndex--
    }

    function getTab(tabIndex) {
        return _tabModel.get(tabIndex)
    }
}
