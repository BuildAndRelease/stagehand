// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library stagehand.analytics_impl_test;

import 'dart:async';

import 'package:stagehand/analytics/src/analytics_impl.dart';
import 'package:unittest/unittest.dart';

void main() => defineTests();

void defineTests() {
  group('ThrottlingBucket', () {
    test('can send', () {
      ThrottlingBucket bucket = new ThrottlingBucket(20);
      expect(bucket.removeDrop(), true);
    });

    test('doesn\'t send too many', () {
      ThrottlingBucket bucket = new ThrottlingBucket(20);
      for (int i = 0; i < 20; i++) {
        expect(bucket.removeDrop(), true);
      }
      expect(bucket.removeDrop(), false);
    });
  });

  group('analytics_impl', () {
    test('simple', () {
      AnalyticsImplMock mock = new AnalyticsImplMock('UA-0');
      mock.sendScreenView('main');
      expect(mock.disabled, false);
      expect(mock.mockProperties['clientId'], isNotNull);
      expect(mock.mockPostHandler.sentValues, isNot(isEmpty));
    });

    test('respects disabled', () {
      AnalyticsImplMock mock = new AnalyticsImplMock('UA-0');
      mock.disabled = true;
      mock.sendScreenView('main');
      expect(mock.disabled, true);
      expect(mock.mockPostHandler.sentValues, isEmpty);
    });

    test('disable clears clientID', () {
      AnalyticsImplMock mock = new AnalyticsImplMock('UA-0');
      mock.sendScreenView('main');
      expect(mock.disabled, false);
      expect(mock.mockProperties['clientId'], isNotNull);
      String id1 = mock.mockProperties['clientId'];
      mock.disabled = true;
      expect(mock.mockProperties['clientId'], isNot(id1));
    });
  });
}

class AnalyticsImplMock extends AnalyticsImpl {
  MockProperties get mockProperties => properties;
  MockPostHandler get mockPostHandler => postHandler;

  AnalyticsImplMock(String trackingId) :
    super(trackingId, new MockProperties(), new MockPostHandler());
}

class MockProperties extends PersistentProperties {
  Map<String, dynamic> props = {};

  MockProperties() : super('mock');

  dynamic operator[](String key) => props[key];

  void operator[]=(String key, dynamic value) {
    props[key] = value;
  }
}

class MockPostHandler extends PostHandler {
  List<Map> sentValues = [];

  Future sendPost(String url, Map<String, String> parameters) {
    sentValues.add(parameters);

    return new Future.value();
  }
}