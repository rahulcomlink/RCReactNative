import { compareServerVersion, methods } from '../lib/utils';
import { SubscriptionType } from '../definitions/ISubscription';
import { IAvatar } from '../containers/Avatar/interfaces';

const formatUrl = (url: string, size: number, query: string) => `${url}?format=png&size=${size}${query}`;

export const avatarURL = ({
	type,
	text,
	size = 25,
	user = {},
	avatar,
	server,
	avatarETag,
	rid,
	blockUnauthenticatedAccess,
	serverVersion
}: IAvatar): string => {
	let room;
	if (type === SubscriptionType.DIRECT) {
		room = text;
	} else if (rid && !compareServerVersion(serverVersion, '3.6.0', methods.lowerThan)) {
		room = `room/${rid}`;
	} else {
		room = `@${text}`;
	}

	const { id, token } = user;
	let query = '';
	if (id && token && blockUnauthenticatedAccess) {
		query += `&rc_token=${token}&rc_uid=${id}`;
	}
	if (avatarETag) {
		query += `&etag=${avatarETag}`;
	}

	if (avatar) {
		if (avatar.startsWith('http')) {
			return avatar;
		}

		return formatUrl(`${server}${avatar}`, size, query);
	}

	return formatUrl(`${server}/avatar/${room}`, size, query);
};
